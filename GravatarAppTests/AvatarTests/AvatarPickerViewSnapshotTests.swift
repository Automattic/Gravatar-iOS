import Foundation
@testable import GravatarApp
import SnapshotTesting
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct AvatarPickerViewSnapshotTests {
    @MainActor
    @Test
    func emptyAvatarGrid() async throws {
        let viewModel = AvatarPickerViewModel(
            userSession: UserSession(profile: .testProfile, accessToken: "token", context: .testContext),
            urlSession: URLSessionMock(),
            disableAnimations: true
        )
        let view = AvatarPickerView(avatarPickerModel: viewModel, onLogout: {})
            .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0, height: ViewImageConfig.iPhone13Pro.size?.height ?? 0)
        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @MainActor
    @Test
    func noAvatarSelected() async throws {
        let viewModel = AvatarPickerViewModel(
            userSession: UserSession(profile: .testProfile, accessToken: "token", context: .testContext),
            urlSession: URLSessionMock(),
            disableAnimations: true
        )
        await viewModel.fetchAvatars()
        if let selectedAvatar = viewModel.grid.selectedAvatar {
            _ = await viewModel.delete(selectedAvatar)
        }
        let view = AvatarPickerView(avatarPickerModel: viewModel, onLogout: {})
            .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0, height: ViewImageConfig.iPhone13Pro.size?.height ?? 0)
        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }
}
