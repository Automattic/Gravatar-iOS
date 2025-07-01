import Gravatar
import SwiftUI

@MainActor
class EditProfileViewModel: ObservableObject {
    private let authToken: String
    private let profile: Profile
    private let profileService: ProfileService

    @Published var isSaving: Bool = false
    @Published var fields: ProfileFieldsModel
    @Published private(set) var profileSaveResult: Result<Profile, Error>?

    init(
        profile: Profile,
        authToken: String,
        urlSession: URLSessionProtocol? = nil
    ) {
        self.profile = profile
        self.authToken = authToken
        self.profileService = .init(urlSession: urlSession)
        self.fields = .init(profile: profile)
    }

    // TODO: Implement
    
    func save() async {
        do {
            let request = fields.updateRequest()
            let updatedProfile = try await profileService.updateProfile(with: request, token: authToken)
            self.profileSaveResult = .success(updatedProfile)
            //toastManager.showToast(Localized.profileUpdateSuccess, type: .info)
            //return updatedProfile
        } catch APIError.responseError(let .invalidHTTPStatusCode(response, errorPayload))
            where response.statusCode == HTTPStatus.unauthorized.rawValue
        {
            NotificationCenter.default.post(name: .sessionExpired, object: nil)
        } catch {
            profileSaveResult = .failure(error)
            // TODO: Show toast
        }
    }
}
