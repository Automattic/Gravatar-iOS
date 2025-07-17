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
            if let userSession = viewModel.userSession {
                rootView(userSession: userSession)
            } else if viewModel.hasUser || viewModel.isLoading {
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
        .onReceive(NotificationCenter.default.publisher(for: .signOut)) { _ in
            Task {
                await viewModel.logout()
            }
        }
    }

    private func rootView(userSession: UserSession) -> some View {
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
            } else if let error = viewModel.profileFetchingError {
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
    WelcomeView(modelContext: .testContext)
}
