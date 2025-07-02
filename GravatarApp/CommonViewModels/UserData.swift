import Combine
import Gravatar

@MainActor
class UserSession: ObservableObject {
    @Published var profile: Profile
    @Published var accessToken: String

    init(profile: Profile, accessToken: String) {
        self.profile = profile
        self.accessToken = accessToken
    }

    func updateProfile(_ profile: Profile) {
        self.profile = profile
    }
}
