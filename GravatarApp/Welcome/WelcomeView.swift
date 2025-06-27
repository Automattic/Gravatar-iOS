import Gravatar
import OAuth
import SwiftUI

struct WelcomeView: View {
    @StateObject private var viewModel: WelcomeViewModel = .init()

    var body: some View {
        Group {
            if (viewModel.hasUser && viewModel.profileResult == nil) || viewModel.profileViewModel.isLoading == true {
                ProgressView()
            } else if let profileResult = viewModel.profileResult,
                      let accessToken = viewModel.accessToken
            {
                switch profileResult {
                case .success(let profile):
                    RootTabView(
                        authToken: accessToken,
                        profile: profile
                    ) {
                        Task {
                            await viewModel.logout()
                        }
                    }
                    .transition(.opacity)
                case .failure(let error):
                    Text("Error fetching the profile: \(error)")
                        .padding()
                }
            } else {
                loginView
            }
        }.onAppear {
            viewModel.softLogin()
        }
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
