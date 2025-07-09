import Foundation
import Gravatar
import SwiftData

@Model
class ProfileStore {
    @Attribute(.unique) var userHash: String
    @Attribute var profileDescription: Data

    var profile: Profile? {
        do {
            return try JSONDecoder().decode(Profile.self, from: profileDescription)
        } catch {
            return nil
        }
    }

    init(profile: Profile) {
        self.userHash = profile.hash
        do {
            profileDescription = try JSONEncoder().encode(profile)
        } catch {
            self.profileDescription = Data()
        }
    }
}
