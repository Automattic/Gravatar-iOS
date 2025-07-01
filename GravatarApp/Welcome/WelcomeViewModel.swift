import Analytics
import Combine
import Foundation
import Gravatar
import OAuth
import SwiftUI

@MainActor
class WelcomeViewModel: ObservableObject {
    @Published var oauthError: Error?
    @Published var profileFetchingError: APIError?
    @Published var accessToken: String? {
        didSet {
            if let accessToken, accessToken != oldValue {
                Task {
                    await self.profileViewModel.fetchProfile(with: accessToken)
                    await self.userSession.updateAccessToken(accessToken)
                }
            }
        }
    }

    @Published var profileViewModel: ProfileViewModel
    @Published var profileResult: Result<Profile, APIError>?
    private var cancellables = Set<AnyCancellable>()
    private let oauthManager: OAuthManager
    private let analytics: Analytics
    private let userDefaults: UserDefaults
    private let userSession: UserSession

    init(
        oauthManager: OAuthManager = .shared,
        userDefaults: UserDefaults = .standard,
        analytics: Analytics = .shared,
        userSession: UserSession = .shared,
        profileService: ProfileServiceProtocol = Gravatar.ProfileService()
    ) {
        self.oauthManager = oauthManager
        self.analytics = analytics
        self.userDefaults = userDefaults
        self.userSession = userSession
        self.profileViewModel = .init(userDefaults: userDefaults, profileService: profileService)

        initCombine()
    }

    private func initCombine() {
        $accessToken
            .combineLatest(profileViewModel.$profileResult)
            .compactMap { accessToken, profileResult -> (String, Result<Profile, APIError>)? in
                guard let accessToken, let profileResult else {
                    return nil
                }
                return (accessToken, profileResult)
            }
            .sink { [weak self] newToken, profileResult in
                guard let self else { return }
                self.handleProfileFetch(accessToken: newToken, profileResult: profileResult)
            }
            .store(in: &cancellables)
    }

    private func handleProfileFetch(accessToken: String, profileResult newResult: Result<Profile, APIError>) {
        switch newResult {
        case .success(let profile):
            self.oauthManager.saveToken(AccessToken(token: accessToken), withKey: profile.hash)
            Task {
                await analytics.setUserName(profile.userLogin)
                await userSession.updateProfile(profile)
            }
        case .failure:
            break
        }
        withAnimation {
            self.profileResult = newResult
        }
    }

    func softLogin() {
        guard
            let currentUser = userDefaults.string(forKey: .Gravatar.currentUserKey),
            let secureToken = oauthManager.sessionToken(with: currentUser)
        else { return }

        self.accessToken = secureToken.token
    }

    var hasUser: Bool {
        guard let currentUser = userDefaults.string(forKey: .Gravatar.currentUserKey)
        else { return false }
        return oauthManager.sessionToken(with: currentUser) != nil
    }

    func logout() async {
        guard let profile = profileResult?.value() else { return }
        oauthManager.deleteToken(with: profile.hash)
        await analytics.setUserName(nil)
        await userSession.updateProfile(nil)
        withAnimation {
            self.accessToken = nil
            self.profileResult = nil
        }
    }

    func requestOAuthToken() async {
        analytics.track(WelcomeScreenEvent.authButtonPressed)
        oauthError = nil
        do {
            self.accessToken = try await oauthManager.requestAccessToken().token
            analytics.track(WelcomeScreenEvent.authSuccess)
        } catch {
            self.oauthError = error
        }
    }
}
