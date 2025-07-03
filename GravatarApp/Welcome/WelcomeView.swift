import Gravatar
import OAuth
import SwiftData
import SwiftUI

struct WelcomeView: View {
    @StateObject private var viewModel: WelcomeViewModel
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        _viewModel = .init(wrappedValue: WelcomeViewModel(context: modelContext))
    }

    var body: some View {
        Group {
            if
                let profileResult = viewModel.profileResult,
                let userSession = viewModel.userSession
            {
                rootView(profileResult: profileResult, userSession: userSession)
            } else if (viewModel.hasUser && viewModel.profileResult == nil) || viewModel.isLoading {
                ProgressView()
            } else {
                loginView
            }
        }
        .modelContext(modelContext)
        .onAppear {
            viewModel.softLogin()
        }
        .onReceive(NotificationCenter.default.publisher(for: .sessionExpired)) { _ in
            Task {
                await viewModel.logout()
            }
        }
    }

    @ViewBuilder
    private func rootView(profileResult: Result<Profile, APIError>, userSession: UserSession) -> some View {
        switch profileResult {
        case .success:
            rootViewSuccess(userSession: userSession)
        case .failure(let error):
            Text("Error fetching the profile: \(error)")
                .padding()
        }
    }

    private func rootViewSuccess(userSession: UserSession) -> some View {
        RootTabView(userSession: userSession, context: modelContext) {
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

// #Preview {
//    WelcomeView()
// }
