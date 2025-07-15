import Foundation
@testable import GravatarApp
import SnapshotTesting
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct AvatarPickerViewSnapshotTests {
    @MainActor
    @Test("AvatarPickerView displays correctly if the fetched avatars grid is empty")
    func emptyAvatarGrid() async throws {
        let viewModel = AvatarPickerViewModel(
            userSession: UserSession(profile: .testProfile, accessToken: "token", context: .testContext),
            urlSession: URLSessionMock(shouldFetchEmptyAvatarsGrid: true)
        )
        await viewModel.fetchAvatars()
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
            urlSession: URLSessionMock()
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

    @MainActor
    @Test("AvatarPickerView displays correctly if the fetching happens when the grid is empty)", arguments: [true, false])
    func avatarFetchingWhenGirdIsEmpty(isSuccess: Bool) async throws {
        let viewModel = AvatarPickerViewModel(
            userSession: UserSession(profile: .testProfile, accessToken: "token", context: .testContext),
            urlSession: URLSessionMock(returnErrorCode: isSuccess ? nil : 400)
        )
        await viewModel.fetchAvatars()
        let view = AvatarPickerView(avatarPickerModel: viewModel, onLogout: {})
            .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0, height: ViewImageConfig.iPhone13Pro.size?.height ?? 0)
        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ],
            testName: "avatarFetchingWhenGirdIsEmpty-\(isSuccess ? "success" : "error")"
        )
    }

    @MainActor
    @Test("AvatarPickerView displays correctly if the fetching happens when the grid is NOT empty)", arguments: [true, false])
    func avatarFetchingWhenGirdIsNotEmpty(isSuccess: Bool) async throws {
        let sessionMock = URLSessionMock()
        let viewModel = AvatarPickerViewModel(
            userSession: UserSession(profile: .testProfile, accessToken: "token", context: .testContext),
            urlSession: sessionMock
        )
        // First attempt is successful and we fill the grid.
        await viewModel.fetchAvatars()

        sessionMock.returnErrorCode = isSuccess ? nil : 400

        // Second attempt depends on the `isSuccess` flag.
        await viewModel.fetchAvatars()

        let view = AvatarPickerView(avatarPickerModel: viewModel, onLogout: {})
            .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0, height: ViewImageConfig.iPhone13Pro.size?.height ?? 0)
        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ],
            testName: "avatarFetchingWhenGirdIsNotEmpty-\(isSuccess ? "success" : "error")"
        )
    }
}
