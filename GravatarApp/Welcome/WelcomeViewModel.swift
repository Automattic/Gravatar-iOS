import Analytics
import Combine
import Foundation
import Gravatar
import OAuth
import SwiftData
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
                }
            }
        }
    }

    @Published var profileViewModel: ProfileViewModel
    @Published var profileResult: Result<Profile, APIError>?
    @Published var isLoading: Bool = false
    @Published var userSession: UserSession?

    private var cancellables = Set<AnyCancellable>()
    private let oauthManager: OAuthManager
    private let analytics: Analytics
    private let userDefaults: UserDefaults
    private let context: ModelContext
    private var storedProfile: Profile?

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
        self.profileViewModel = .init(userDefaults: userDefaults, profileService: profileService)
        self.context = context

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

        profileViewModel.$isLoading.sink { [weak self] newValue in
            self?.isLoading = newValue
        }
        .store(in: &cancellables)
    }

    private func handleProfileFetch(accessToken: String, profileResult newResult: Result<Profile, APIError>) {
        switch newResult {
        case .success(let profile):
            configureSession(profile: profile, accessToken: accessToken)
        case .failure:
            withAnimation {
                if let storedProfile {
                    // Continue with the stored profile
                    configureSession(profile: storedProfile, accessToken: accessToken)
                } else {
                    profileResult = newResult
                }
            }
        }
    }

    private func configureSession(profile: Profile, accessToken: String) {
        self.oauthManager.saveToken(AccessToken(token: accessToken), withKey: profile.hash)
        Task {
            await analytics.setUserName(profile.userLogin)
        }
        withAnimation {
            if let userSession {
                userSession.updateProfile(profile)
            } else {
                userSession = .init(profile: profile, accessToken: accessToken, context: context)
                context.insert(ProfileStore(profile: profile))
                context.saveNow()
            }
            profileResult = .success(profile)
        }
    }

    func softLogin() {
        guard
            let currentUser = userDefaults.string(forKey: .Gravatar.currentUserKey),
            let secureToken = oauthManager.sessionToken(with: currentUser)
        else { return }

        let descriptor = FetchDescriptor<ProfileStore>(predicate: #Predicate { $0.userHash == currentUser })

        if let profile = try? context.fetch(descriptor).first?.profile {
            storedProfile = profile
            configureSession(profile: profile, accessToken: secureToken.token)
            withAnimation {
                self.profileResult = .success(profile)
            }
        }

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
        withAnimation {
            userSession = nil
            accessToken = nil
            profileResult = nil
            profileViewModel.removeResult()
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
