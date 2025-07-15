import Gravatar
import OAuth
import SwiftData
import SwiftUI

struct WelcomeView: View {
    @StateObject private var viewModel: WelcomeViewModel

    init(viewModel: WelcomeViewModel, userDefaults: UserDefaults = .standard) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if let userSession = viewModel.userSession {
                rootView(userSession: userSession)
            } else {
                loginView
            }
        }
        .modelContext(viewModel.context)
        .onAppear {
            viewModel.softLogin()
        }
        .onReceive(NotificationCenter.default.publisher(for: .sessionExpired)) { _ in
            Task {
                await viewModel.logout()
            }
        }
    }

    private func rootView(userSession: UserSession) -> some View {
        RootTabView(userSession: userSession, context: viewModel.context) {
            Task {
                await viewModel.logout()
            }
        }
        .transition(.opacity)
    }

    var loginView: some View {
        VStack {
            Spacer()
            Image(.gravatarLogo).resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 116)
                .foregroundStyle(Color.DS.bluishColor)
            Text("Gravatar")
                .font(.system(size: 50, weight: .heavy))
            Text(verbatim: .loginSubtitle)
                .font(.footnote)
                .foregroundStyle(Color.secondary)
            Spacer()
            if let error = viewModel.oauthError {
                errorView(with: error)
            } else if let error = viewModel.profileFetchingError {
                errorView(with: error)
            }
            VStack(spacing: 22) {
                loginButton
                if viewModel.profileFetchingError != nil {
                    Button {
                        Task {
                            await viewModel.requestOAuthToken()
                        }
                    } label: {
                        Text(verbatim: .loginAnotherAcountButtonTitle)
                    }
                }
            }
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    func errorView(with error: Error) -> some View {
        switch error {
        case let error as OAuthError where error.isAccessDenied:
            errorView(title: .oauthDeniedErrorMessage)
        case OAuthError.tokenRequestError(let urlError):
            // If the connection is not secure, OAuth will return a URLError.
            errorView(title: .oauthGenericErrorMessage, subtitle: urlError.localizedDescription)
        case APIError.responseError(reason: let reason) where reason.urlSessionErrorLocalizedDescription != nil:
            errorView(title: .profileErrorTitle, subtitle: reason.urlSessionErrorLocalizedDescription)
        case is APIError:
            errorView(title: .profileErrorTitle, subtitle: .profileErrorMessage)
        default:
            EmptyView()
        }
    }

    func errorView(title: String, subtitle: String? = nil) -> some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            if let subtitle {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
    }

    var loginButton: some View {
        Button {
            Task {
                if viewModel.profileFetchingError != nil, let token = viewModel.localAccessToken {
                    await viewModel.fetchProfile(with: token)
                } else {
                    await viewModel.requestOAuthToken()
                }
            }
        } label: {
            Text(verbatim: viewModel.profileFetchingError == nil ?
                .loginButtonTitle :
                .tryAgainButtonTitle
            )
            .frame(maxWidth: .infinity)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .padding(.vertical, 12)
        .background(viewModel.isLoading ? Color(uiColor: .systemFill) : Color.DS.bluishColor)
        .foregroundStyle(Color.white)
        .clipShape(.capsule)
        .padding(.horizontal, 16)
    }
}

extension String {
    enum Gravatar {
        static let currentUserKey = "com.gravatar.currentUser"
    }

    static let loginSubtitle = NSLocalizedString(
        "Welcome.Logo.subtitle",
        value: "Your globally recognized avatar.",
        comment: "Subtitle for the login screen"
    )

    static let loginButtonTitle = NSLocalizedString(
        "Welcome.Login.MainButton.title",
        value: "Login",
        comment: "Title for the main login button."
    )

    static let tryAgainButtonTitle = NSLocalizedString(
        "Welcome.Login.TryAgainButton.title",
        value: "Try again",
        comment: "Title for the button to try again after a login failure."
    )

    static let loginAnotherAcountButtonTitle = NSLocalizedString(
        "Welcome.Login.AnotherAccountButton.title",
        value: "Try with another account",
        comment: "Title for the button to login with another account."
    )

    static let oauthDeniedErrorMessage = NSLocalizedString(
        "Welcome.Error.OAuth.Denied.message",
        value: "You need to log in to Gravatar.com.",
        comment: "Message for the error when OAuth is denied by the user."
    )

    static let oauthGenericErrorMessage = NSLocalizedString(
        "Welcome.Error.OAuth.Generic.message",
        value: "Unable to request access.",
        comment: "Generic error message when OAuth fails."
    )

    static let profileErrorTitle = NSLocalizedString(
        "Welcome.Error.Profile.title",
        value: "Unable to load your profile.",
        comment: "Title for the error when the profile fetch fails."
    )

    static let profileErrorMessage = NSLocalizedString(
        "Welcome.Error.Profile.Generic.message",
        value: "There was an unknown issue loading your profile.",
        comment: "Generic error message when the profile fetch fails for an unkonwn reason."
    )
}

#Preview {
    WelcomeView(viewModel: .init(context: .testContext))
}
