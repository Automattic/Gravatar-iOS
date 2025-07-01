import Combine
import Gravatar

@MainActor
class UserSession: ObservableObject {
    static let shared = UserSession() // single shared instance

    @Published var profile: Profile?
    @Published var accessToken: String?

    func updateProfile(_ profile: Profile?) {
        self.profile = profile
    }

    func updateAccessToken(_ accessToken: String?) {
        self.accessToken = accessToken
    }
}
