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
        fields.hasDifference(comparedTo: userSession.profile)
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
            guard let self else { return }
            if self.fields.hasDifference(comparedTo: profile) { // just to avoid unnecessary re-render
                self.fields = .init(profile: profile)
            }
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
            // BE trims whitespaces, thus, userSession.$profile doesn't notice any changes if the
            // changes consist of just excess whitespaces.
            // But the UI still has them. This makes sure the UI state is synced with server:
            fields = .init(profile: profile)
            // Update the rest of the app:
            userSession.updateProfile(profile)
            toastManager.showToast(ProfileEditLocalization.profileSavedSuccessMessage)
        } catch {
            showToast(for: error, fallbackText: ProfileEditLocalization.profileSavedErrorMessage)
        }
    }

    func fetchProfile() async {
        do {
            let profile = try await profileService.fetchOwnProfile(token: userSession.accessToken)
            userSession.updateProfile(profile)
        } catch {
            showToast(for: error, fallbackText: ProfileEditLocalization.profileSavedErrorMessage)
        }
    }

    func hasDifference(in field: ProfileField) -> Bool {
        fields.hasDifference(in: field, comparedTo: userSession.profile)
    }

    func showToast(for error: Error, fallbackText: String) {
        let message: String = switch error {
        case APIError.responseError(reason: let reason):
            reason.urlSessionErrorLocalizedDescription ?? fallbackText
        default:
            fallbackText
        }
        toastManager.showToast(message, type: .error)
    }
}
