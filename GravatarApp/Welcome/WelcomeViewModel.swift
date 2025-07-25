import Analytics
import Gravatar
import OAuth
import SwiftData
import SwiftUI

@MainActor
class WelcomeViewModel: ObservableObject {
    @Published var oauthError: OAuthError?
    @Published var profileFetchingError: APIError?

    @Published var isLoading: Bool = false
    @Published var userSession: UserSession?

    /// This property will have a value only in the case an OAuth request succeed and the profile request fails.
    /// Used to retry the Profile request.
    var localAccessToken: String?
    let context: ModelContext

    private let profileService: any ProfileServiceProtocol
    private let oauthManager: OAuthManager
    private let analytics: Analytics
    private let userDefaults: UserDefaults

    init(
        oauthManager: OAuthManager = .shared,
        userDefaults: UserDefaults = .standard,
        analytics: Analytics = .shared,
        profileService: ProfileServiceProtocol = Gravatar.ProfileService(urlSession: GravatarURLSession.shared),
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
            cleanAllErrors()
        } catch {
            localAccessToken = token
            withAnimation(.smooth(duration: 0.2)) {
                profileFetchingError = error as? APIError
            }
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

    private func softLoginConfiguration(profile: Profile, accessToken: String) {
        userSession = .init(profile: profile, accessToken: accessToken, context: context)
        Task {
            await analytics.setUserName(profile.userLogin)
        }
    }

    func softLogin() {
        guard
            let currentUserHash = userDefaults.string(forKey: .Gravatar.currentUserKey),
            let accessToken = oauthManager.sessionToken(with: currentUserHash)?.token
        else { return }

        let descriptor = FetchDescriptor<ProfileStore>(predicate: #Predicate { $0.userHash == currentUserHash })

        if let profile = try? context.fetch(descriptor).first?.profile {
            softLoginConfiguration(profile: profile, accessToken: accessToken)
        }

        Task {
            await fetchProfile(with: accessToken)
        }
    }

    func logout() async {
        guard let profile = userSession?.profile else { return }

        oauthManager.deleteToken(with: profile.hash)
        await analytics.setUserName(nil)
        userDefaults.set(nil, forKey: .Gravatar.currentUserKey)
        try? context.delete(model: ProfileStore.self)
        context.saveNow()
        localAccessToken = nil

        withAnimation {
            self.userSession = nil
        }
    }

    func cleanAllErrors() {
        withAnimation(.smooth(duration: 0.2)) {
            oauthError = nil
            profileFetchingError = nil
        }
    }

    func requestOAuthToken() async {
        analytics.track(WelcomeScreenEvent.authButtonPressed)
        localAccessToken = nil
        do {
            isLoading = true
            let token = try await oauthManager.requestAccessToken().token
            await fetchProfile(with: token)
            analytics.track(WelcomeScreenEvent.authSuccess)
        } catch {
            withAnimation {
                self.oauthError = error
            }

            isLoading = false
        }
    }
}
