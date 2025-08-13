import Analytics
import Combine
import Gravatar
import OAuth
import SwiftData
import SwiftUI

@MainActor
class WelcomeViewModel: ObservableObject {
    @Published var oauthError: OAuthError?
    @Published var oauthAlertErrorMessage: String?
    @Published var profileFetchingError: APIError?

    @Published var isLoading: Bool = false
    @Published var userSession: UserSession?
    @Published var isDeletingAccount: Bool = false
    @Published var accountDeletionError: String?
    @Published var noInernetConnection: Bool = false

    /// This property will have a value only in the case an OAuth request succeed and the profile request fails.
    /// Used to retry the Profile request.
    var localAccessToken: String?
    let context: ModelContext

    private let profileService: any ProfileServiceProtocol
    private let oauthManager: OAuthManager
    private let analytics: Analytics
    private let userDefaults: UserDefaults
    private let networkMonitor: any NetworkMonitor
    private var cancellables = Set<AnyCancellable>()

    init(
        oauthManager: OAuthManager = .shared,
        userDefaults: UserDefaults = .standard,
        analytics: Analytics = .shared,
        profileService: ProfileServiceProtocol = Gravatar.ProfileService(urlSession: GravatarURLSession.shared),
        context: ModelContext,
        networkMonitor: any NetworkMonitor = SystemNetworkMonitor.shared
    ) {
        self.oauthManager = oauthManager
        self.analytics = analytics
        self.userDefaults = userDefaults
        self.profileService = profileService
        self.context = context
        self.networkMonitor = networkMonitor

        networkMonitor.hasNetworkConnection.sink { [weak self] isConnected in
            withAnimation(.smooth(duration: 0.2)) {
                self?.noInernetConnection = !isConnected
            }
        }.store(in: &cancellables)
    }

    func fetchProfile(with token: String) async {
        defer {
            isLoading = false
        }
        do {
            isLoading = true
            analytics.track(WelcomeScreenEvent.profileFetchStart)
            let profile = try await profileService.fetchOwnProfile(token: token)
            analytics.track(WelcomeScreenEvent.profileFetchSuccess)
            await configureSession(profile: profile, accessToken: token)
            cleanAllErrors()
        } catch {
            if let error = error as? APIError { // Always the case (we need typed throws from the SDK)
                analytics.track(WelcomeScreenEvent.profileFetchError(error: error.debugDescription))
            }
            localAccessToken = token
            withAnimation(.smooth(duration: 0.2)) {
                profileFetchingError = error as? APIError
            }
        }
    }

    private func configureSession(profile: Profile, accessToken: String) async {
        self.oauthManager.saveToken(AccessToken(token: accessToken), withKey: profile.hash)

        await analytics.setUserName(profile.userLogin)
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

    var hasUserSession: Bool {
        guard let currentUserHash = userDefaults.string(forKey: .Gravatar.currentUserKey) else { return false }
        return oauthManager.sessionToken(with: currentUserHash)?.token != nil
    }

    func logout() async {
        guard let profile = userSession?.profile else { return }

        oauthManager.deleteToken(with: profile.hash)
        await analytics.setUserName(nil)
        userDefaults.set(nil, forKey: .Gravatar.currentUserKey)
        try? context.delete(model: ProfileStore.self)
        context.saveNow()
        localAccessToken = nil
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            userDefaults.removePersistentDomain(forName: bundleIdentifier)
        }

        withAnimation {
            self.userSession = nil
        }
    }

    func deleteAccount() async {
        guard let userSession else { return }
        defer {
            withAnimation {
                isDeletingAccount = false
            }
        }
        withAnimation {
            isDeletingAccount = true
        }

        let service = AccountService(userSession: userSession)
        do {
            try await service.deleteAccount()
            await logout()
        } catch {
            accountDeletionError = error.localizedDescription.isEmpty ? Localized.unknownError : error.localizedDescription
        }
    }

    func cleanAllErrors() {
        withAnimation(.smooth(duration: 0.2)) {
            oauthError = nil
            profileFetchingError = nil
        }
    }

    func requestOAuthToken() async {
        localAccessToken = nil
        do {
            isLoading = true
            analytics.track(WelcomeScreenEvent.oauthStart)
            let token = try await oauthManager.requestAccessToken().token
            analytics.track(WelcomeScreenEvent.oauthSuccess)
            await fetchProfile(with: token)
        } catch {
            switch error {
            case let error where error.isAccessDenied || error.isCancelled:
                analytics.track(WelcomeScreenEvent.oauthCancelled)
            case let error where error.isAssociatedDomainError:
                oauthAlertErrorMessage = Localized.secureLoginErrorMessage
                analytics.track(WelcomeScreenEvent.oauthError(error: error.errorDescription))
            default:
                oauthAlertErrorMessage = error.errorDescription
                analytics.track(WelcomeScreenEvent.oauthError(error: error.errorDescription))
            }
            withAnimation {
                self.oauthError = error
            }
            isLoading = false
        }
    }
}

private enum Localized {
    static let unknownError = NSLocalizedString(
        "Welcome.accountDeletion.unknownError",
        value: "An unknown error has occurred while deleting your account",
        comment: "Error message shown when an unknown error occurs while deleting an account"
    )

    static let secureLoginErrorMessage = NSLocalizedString(
        "Welcome.OAuth.secureLoginErrorMessage",
        value: "Setting up secure login… Please try again in a few seconds.",
        comment: "Error message shown when associated domain setup hasn't finished yet"
    )
}
