import Combine
import Gravatar
import SwiftUI

@MainActor
class EditProfileViewModel: ObservableObject {
    private let profileService: ProfileService
    private let userSession: UserSession
    private var cancellables = Set<AnyCancellable>()

    @Published var isSaving: Bool = false
    @Published var fields: ProfileFieldsModel

    private var networkMonitor: any NetworkMonitor

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
        self.networkMonitor = networkMonitor

        self.fields = .init(profile: userSession.profile)

        setupCombine()
    }

    private func setupCombine() {
        userSession.$profile.sink { [weak self] profile in
            self?.fields = .init(profile: profile)
        }
        .store(in: &cancellables)
        networkMonitor.hasNetworkConnection.dropFirst().sink { [weak self] newValue in
            if newValue {
                Task {
                    await self?.fetchProfile()
                }
            }
        }.store(in: &cancellables)
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
}
