import Gravatar
import SwiftUI

@MainActor
class EditProfileViewModel: ObservableObject {
    private let authToken: String
    let profile: Profile

    init(
        profile: Profile,
        authToken: String
    ) {
        self.profile = profile
        self.authToken = authToken
    }

    // TODO: Implement
}
