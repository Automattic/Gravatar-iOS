import Combine
import Gravatar
import SwiftData

@MainActor
class UserSession: ObservableObject {
    @Published var profile: Profile
    @Published var accessToken: String

    var context: ModelContext

    init(profile: Profile, accessToken: String, context: ModelContext) {
        self.profile = profile
        self.accessToken = accessToken
        self.context = context
    }

    func updateProfile(_ profile: Profile) {
        guard self.profile != profile else { return }

        self.profile = profile
        context.insert(ProfileStore(profile: profile))
        context.saveNow()
    }
}
