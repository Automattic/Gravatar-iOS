import Combine
import Foundation
import Gravatar
import SwiftData

@MainActor
class UserSession: ObservableObject {
    @Published var profile: Profile
    @Published var accessToken: String

    var context: ModelContext

    private let networkMonitor: NetworkMonitor
    private let profileService: ProfileService
    private var cancellables = Set<AnyCancellable>()

    init(
        profile: Profile,
        accessToken: String,
        context: ModelContext,
        networkMonitor: NetworkMonitor = SystemNetworkMonitor.shared,
        urlSession: URLSessionProtocol = URLSession.shared
    ) {
        self.profile = profile
        self.accessToken = accessToken
        self.context = context
        self.networkMonitor = networkMonitor
        self.profileService = ProfileService(urlSession: urlSession)
        setupCombine()
    }

    func setupCombine() {
        networkMonitor.hasNetworkConnection.dropFirst().sink { [weak self] hasConnection in
            guard let self, hasConnection else { return }
            Task {
                let profile = try await profileService.fetchOwnProfile(token: accessToken)
                updateProfile(profile)
            }
        }.store(in: &cancellables)
    }

    func updateProfile(_ profile: Profile) {
        guard self.profile != profile else { return }

        self.profile = profile
        context.insert(ProfileStore(profile: profile))
        context.saveNow()
    }
}
