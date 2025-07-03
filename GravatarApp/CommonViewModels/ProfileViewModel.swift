import Gravatar
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var profileResult: Result<Profile, APIError>?
    private let profileService: ProfileService
    private let userDefaults: UserDefaults

    init(
        userDefaults: UserDefaults = .standard,
        urlSession: URLSessionProtocol = GravatarURLSession.shared,
    ) {
        self.userDefaults = userDefaults
        self.profileService = ProfileService(urlSession: urlSession)
    }

    func fetchProfile(with token: String) async {
        defer {
            isLoading = false
        }
        do {
            isLoading = true
            let profile = try await profileService.fetchOwnProfile(token: token)
            userDefaults.set(profile.hash, forKey: .Gravatar.currentUserKey)
            profileResult = .success(profile)
        } catch let error as APIError {
            profileResult = .failure(error)
        } catch {
            profileResult = .failure(.responseError(reason: .unexpected(error)))
        }
    }

    func removeResult() {
        profileResult = nil
    }
}
