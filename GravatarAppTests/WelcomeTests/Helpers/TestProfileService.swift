import Gravatar
@testable import GravatarApp

final class TestProfileService: ProfileServiceProtocol, @unchecked Sendable {
    var error: APIError?

    func fetchOwnProfile(token: String) async throws -> Gravatar.Profile {
        if let error {
            throw error
        }
        return Profile.full
    }
}
