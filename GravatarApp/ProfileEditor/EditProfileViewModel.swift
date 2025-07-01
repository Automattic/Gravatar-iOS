import Gravatar
import SwiftUI

@MainActor
class EditProfileViewModel: ObservableObject {
    private let authToken: String
    private let profileService: ProfileService
    private(set) var profile: Profile {
        didSet {
            fields = .init(profile: profile)
        }
    }

    @Published var isSaving: Bool = false
    @Published var fields: ProfileFieldsModel
    var isSavinDisabled: Bool {
        !hasUnsavedChanges || isSaving
    }

    var hasUnsavedChanges: Bool {
        !fields.isEqual(to: profile)
    }

    init(
        profile: Profile,
        authToken: String,
        urlSession: URLSessionProtocol? = nil
    ) {
        self.authToken = authToken
        self.profile = profile
        self.profileService = .init(urlSession: urlSession)
        self.fields = .init(profile: profile)
    }

    // TODO: Implement

    func save() async {
        defer {
            isSaving = false
        }
        do {
            isSaving = true
            let request = fields.updateRequest()
            self.profile = try await profileService.updateProfile(with: request, token: authToken)
            print("success!")
            // TODO: Show success toast
        } catch APIError.responseError(let .invalidHTTPStatusCode(response, errorPayload))
            where response.statusCode == HTTPStatus.unauthorized.rawValue
        {
            NotificationCenter.default.post(name: .sessionExpired, object: nil)
        } catch {
            print("error: \(error)")
            // TODO: Show error toast
        }
    }
}
