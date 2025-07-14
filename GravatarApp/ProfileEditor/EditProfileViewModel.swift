import Combine
import Gravatar
import SwiftUI

@MainActor
class EditProfileViewModel: ObservableObject {
    private let profileService: ProfileService
    let userSession: UserSession
    private let toastManager: ToastManager
    private var cancellables = Set<AnyCancellable>()

    @Published var isSaving: Bool = false
    @Published var fields: ProfileFieldsModel

    var isSavinDisabled: Bool {
        !hasUnsavedChanges || isSaving
    }

    var hasUnsavedChanges: Bool {
        !fields.isEqual(to: userSession.profile)
    }

    init(
        userSession: UserSession,
        toastManager: ToastManager = ToastManager(),
        urlSession: URLSessionProtocol = GravatarURLSession.shared,
        networkMonitor: any NetworkMonitor = SystemNetworkMonitor.shared
    ) {
        self.userSession = userSession
        self.profileService = .init(urlSession: urlSession)

        self.fields = .init(profile: userSession.profile)
        self.toastManager = toastManager

        setupCombine()
    }

    private func setupCombine() {
        userSession.$profile.sink { [weak self] profile in
            self?.fields = .init(profile: profile)
        }
        .store(in: &cancellables)
    }

    func save() async {
        defer {
            isSaving = false
        }
        do {
            isSaving = true
            let request = fields.updateRequest()
            let profile = try await profileService.updateProfile(with: request, token: userSession.accessToken)
            Task { @MainActor in
                userSession.updateProfile(profile)
            }
            toastManager.showToast(ProfileEditLocalization.profileSavedSuccessMessage)
        } catch APIError.responseError(reason: let reason) {
            let message = reason.urlSessionErrorLocalizedDescription ?? ProfileEditLocalization.profileSavedErrorMessage
            toastManager.showToast(message, type: .error)
        } catch {
            toastManager.showToast(ProfileEditLocalization.profileSavedErrorMessage, type: .error)
        }
    }

    func fetchProfile() async {
        do {
            let profile = try await profileService.fetchOwnProfile(token: userSession.accessToken)
            userSession.updateProfile(profile)
        } catch {}
    }
}
