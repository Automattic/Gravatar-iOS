import Gravatar
import SwiftUI

@MainActor
class ProfileService {
    @Published private(set) var isLoading: Bool = false
    private let profileService: Gravatar.ProfileService

    public init(profileService: Gravatar.ProfileService = Gravatar.ProfileService()) {
        self.profileService = profileService
    }

    public func fetchProfile(with token: String) async throws(APIError) -> Profile {
        defer {
            isLoading = false
        }
        do {
            isLoading = true
            let profile = try await profileService.fetchOwnProfile(token: token)
            UserDefaults.standard.set(profile.hash, forKey: .Gravatar.currentUserKey)
            return profile
        } catch let error as APIError {
            throw error
        } catch {
            throw .responseError(reason: .unexpected(error))
        }
    }
}
