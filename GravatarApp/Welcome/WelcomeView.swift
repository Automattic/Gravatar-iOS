import Gravatar
import OAuth
import SwiftUI

struct WelcomeView: View {
    @Environment(\.oauthManager) var oauthManager
    @Environment(\.analytics) var analytics

    @State var error: Error?
    @State var profile: Profile?

    let profileService = ProfileService()

    var body: some View {
        Group {
            if profileService.isLoading {
                ProgressView()
            } else if let profile {
                RootTabView(profile: profile) {
                    Task {
                        await logout()
                    }
                }
                .transition(.opacity)
            } else {
                loginView
            }
        }.onAppear {
            softLogin()
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
                    await requestOAuthToken()
                }
            }.buttonStyle(.borderedProminent)
            Spacer()
            if let error {
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

    func setProfile(to profile: Profile?) async {
        await analytics.setUserName(profile?.userLogin)

        withAnimation {
            self.profile = profile
        }
    }

    func softLogin() {
        guard
            let currentUser = UserDefaults.standard.string(forKey: .Gravatar.currentUserKey),
            let token = oauthManager.sessionToken(with: currentUser)
        else { return }

        // This can be replaced by storing the logged-in profile on device.
        Task {
            do {
                _ = try await requestProfile(with: token.token)
            } catch {
                self.error = error
            }
        }
    }

    func logout() async {
        guard let profile else { return }
        oauthManager.deleteToken(with: profile.hash)
        await setProfile(to: nil)
    }

    func requestOAuthToken() async {
        analytics.track(WelcomeScreenEvent.authButtonPressed)
        error = nil
        do {
            let accessToken = try await oauthManager.requestAccessToken()
            let profile = try await requestProfile(with: accessToken.token)
            analytics.track(WelcomeScreenEvent.authSuccess)
            oauthManager.saveToken(accessToken, withKey: profile.hash)
        } catch {
            self.error = error
        }
    }

    func requestProfile(with token: String) async throws(APIError) -> Profile {
        let profile = try await profileService.fetchProfile(with: token)
        await setProfile(to: profile)
        return profile
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
