import Combine
import Gravatar
import SwiftUI

@MainActor
class EditProfileViewModel: ObservableObject {
    private let profileService: ProfileService
    let userSession: UserSession
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
        urlSession: URLSessionProtocol = GravatarURLSession.shared,
        networkMonitor: any NetworkMonitor = SystemNetworkMonitor.shared
    ) {
        self.userSession = userSession
        self.profileService = .init(urlSession: urlSession)

        self.fields = .init(profile: userSession.profile)

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
            fields.trimWhitespaces()
            let request = fields.updateRequest()
            let profile = try await profileService.updateProfile(with: request, token: userSession.accessToken)
            Task { @MainActor in
                userSession.updateProfile(profile)
            }
            // TODO: Show success toast
        } catch {
            // TODO: Show error toast
        }
    }

    func fetchProfile() async {
        do {
            let profile = try await profileService.fetchOwnProfile(token: userSession.accessToken)
            userSession.updateProfile(profile)
        } catch {}
    }

    func hasUnsavedChanges(_ field: ProfileField, value: Binding<String>) -> Bool {
        switch field {
        case .displayName:
            value.wrappedValue != userSession.profile.displayName
        case .location:
            value.wrappedValue != userSession.profile.location
        case .company:
            value.wrappedValue != userSession.profile.company
        case .aboutMe:
            value.wrappedValue != userSession.profile.description
        case .firstName:
            value.wrappedValue != (userSession.profile.firstName ?? "")
        case .lastName:
            value.wrappedValue != (userSession.profile.lastName ?? "")
        case .pronouns:
            value.wrappedValue != userSession.profile.pronouns
        case .pronunciation:
            value.wrappedValue != userSession.profile.pronunciation
        case .jobTitle:
            value.wrappedValue != userSession.profile.jobTitle
        }
    }
}
