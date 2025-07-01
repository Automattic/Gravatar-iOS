import Gravatar
import OAuth
import SwiftUI

struct WelcomeView: View {
    @StateObject private var viewModel: WelcomeViewModel = .init()
    @StateObject private var session = UserSession.shared

    var body: some View {
        Group {
            if (viewModel.hasUser && viewModel.profileResult == nil) || viewModel.profileViewModel.isLoading == true {
                ProgressView()
            } else if let profileResult = viewModel.profileResult,
                      let accessToken = viewModel.accessToken
            {
                rootView(accessToken: accessToken, profileResult: profileResult)
            } else {
                loginView
            }
        }.onAppear {
            viewModel.softLogin()
        }
        .onReceive(NotificationCenter.default.publisher(for: .sessionExpired)) { _ in
            Task {
                await viewModel.logout()
            }
        }
        .environmentObject(UserSession.shared)
    }

    @ViewBuilder
    private func rootView(accessToken: String, profileResult: Result<Profile, APIError>) -> some View {
        switch profileResult {
        case .success(let profile):
            rootViewSuccess(accessToken: accessToken, profile: profile)
        case .failure(let error):
            Text("Error fetching the profile: \(error)")
                .padding()
        }
    }

    private func rootViewSuccess(accessToken: String, profile: Profile) -> some View {
        RootTabView(
            authToken: accessToken,
            profile: profile
        ) {
            Task {
                await viewModel.logout()
            }
        }
        .transition(.opacity)
    }

    var loginView: some View {
        VStack {
            Spacer()
            Text("Gravatar")
                .font(.largeTitle)
            Spacer()
            Button("Login") {
                Task {
                    await viewModel.requestOAuthToken()
                }
            }.buttonStyle(.borderedProminent)
            Spacer()
            if let error = viewModel.oauthError {
                errorView(with: error)
            }
        }
    }

    @ViewBuilder
    func errorView(with error: Error) -> some View {
        Text(String(describing: error)).onAppear {
            // Temporary for dev purposes
            print("Error: \(error)")
        }
        Spacer()
    }
}

extension String {
    enum Gravatar {
        static let currentUserKey = "com.gravatar.currentUser"
    }
}

#Preview {
    WelcomeView()
}
