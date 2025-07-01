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

    var isSavinDisabled: Bool {
        !hasUnsavedChanges || isSaving
    }

    var hasUnsavedChanges: Bool {
        guard let profile = userSession.profile else {
            return false
        }
        return !fields.isEqual(to: profile)
    }

    init(
        userSession: UserSession = .shared,
        urlSession: URLSessionProtocol? = nil
    ) {
        self.userSession = userSession
        self.profileService = .init(urlSession: urlSession)
        if let profile = userSession.profile {
            self.fields = .init(profile: profile)
        } else {
            self.fields = .init()
        }
        userSession.$profile.sink { [weak self] profile in
            guard let profile else { return }
            self?.fields = .init(profile: profile)
        }
        .store(in: &cancellables)
    }

    // TODO: Implement

    func save() async {
        guard let authToken = userSession.accessToken else { return }
        defer {
            isSaving = false
        }
        do {
            isSaving = true
            let request = fields.updateRequest()
            let profile = try await profileService.updateProfile(with: request, token: authToken)
            Task { @MainActor in
                self.userSession.updateProfile(profile)
            }
            // TODO: Show success toast
        } catch APIError.responseError(let .invalidHTTPStatusCode(response, _))
            where response.statusCode == HTTPStatus.unauthorized.rawValue
        {
            NotificationCenter.default.post(name: .sessionExpired, object: nil)
        } catch {
            // TODO: Show error toast
        }
    }
}
