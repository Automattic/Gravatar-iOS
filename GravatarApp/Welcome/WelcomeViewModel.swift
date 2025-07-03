import Analytics
import Gravatar
import OAuth
import SwiftData
import SwiftUI

@MainActor
class WelcomeViewModel: ObservableObject {
    @Published var oauthError: Error?
    @Published var profileFetchingError: APIError?

    @Published var isLoading: Bool = false
    @Published var userSession: UserSession?

    private let profileService: any ProfileServiceProtocol
    private let oauthManager: OAuthManager
    private let analytics: Analytics
    private let userDefaults: UserDefaults
    private let context: ModelContext

    init(
        oauthManager: OAuthManager = .shared,
        userDefaults: UserDefaults = .standard,
        analytics: Analytics = .shared,
        profileService: ProfileServiceProtocol = Gravatar.ProfileService(),
        context: ModelContext
    ) {
        self.oauthManager = oauthManager
        self.analytics = analytics
        self.userDefaults = userDefaults
        self.profileService = profileService
        self.context = context
    }

    func fetchProfile(with token: String) async {
        defer {
            isLoading = false
        }
        do {
            isLoading = true
            let profile = try await profileService.fetchOwnProfile(token: token)
            configureSession(profile: profile, accessToken: token)
        } catch {
            profileFetchingError = error as? APIError
        }
    }

    private func configureSession(profile: Profile, accessToken: String) {
        self.oauthManager.saveToken(AccessToken(token: accessToken), withKey: profile.hash)

        Task {
            await analytics.setUserName(profile.userLogin)
        }
        userDefaults.set(profile.hash, forKey: .Gravatar.currentUserKey)

        if let userSession {
            userSession.updateProfile(profile)
        } else {
            withAnimation {
                userSession = .init(profile: profile, accessToken: accessToken, context: context)
            }
            context.insert(ProfileStore(profile: profile))
            context.saveNow()
        }
    }

    func softLogin() {
        guard
            let currentUserHash = userDefaults.string(forKey: .Gravatar.currentUserKey),
            let accessToken = oauthManager.sessionToken(with: currentUserHash)?.token
        else { return }

        let descriptor = FetchDescriptor<ProfileStore>(predicate: #Predicate { $0.userHash == currentUserHash })

        Task {
            if let profile = try? context.fetch(descriptor).first?.profile {
                configureSession(profile: profile, accessToken: accessToken)
            }

            await fetchProfile(with: accessToken)
        }
    }

    var hasUser: Bool {
        guard let currentUser = userDefaults.string(forKey: .Gravatar.currentUserKey)
        else { return false }
        return oauthManager.sessionToken(with: currentUser) != nil
    }

    func logout() async {
        guard let profile = userSession?.profile else { return }

        oauthManager.deleteToken(with: profile.hash)
        await analytics.setUserName(nil)
        userDefaults.set(nil, forKey: .Gravatar.currentUserKey)
        try? context.delete(model: ProfileStore.self)
        context.saveNow()

        withAnimation {
            self.userSession = nil
        }
    }

    func requestOAuthToken() async {
        analytics.track(WelcomeScreenEvent.authButtonPressed)
        oauthError = nil
        do {
            isLoading = true
            let token = try await oauthManager.requestAccessToken().token
            await fetchProfile(with: token)
            analytics.track(WelcomeScreenEvent.authSuccess)
        } catch {
            self.oauthError = error
            isLoading = false
        }
    }
}
