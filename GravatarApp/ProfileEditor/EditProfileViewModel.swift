import Gravatar
import SwiftUI

@MainActor
class EditProfileViewModel: ObservableObject {
    private let authToken: String
    private let profile: Profile

    @Published var isSaving: Bool = false
    @Published var fields: ProfileFieldsModel
    init(
        profile: Profile,
        authToken: String
    ) {
        self.profile = profile
        self.authToken = authToken
        self.fields = .init(profile: profile)
    }

    // TODO: Implement
}
