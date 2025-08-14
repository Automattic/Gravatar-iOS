import Analytics
import Foundation
@testable import GravatarApp
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
class AvatarPickerViewSnapshotTests {
    let urlSession = URLSessionMock()

    lazy var viewModel: AvatarPickerViewModel = .init(
        userSession: UserSession(profile: .testProfile, accessToken: "token", context: .testContext),
        urlSession: urlSession
    )

    @Test("AvatarPickerView displays correctly if the fetched avatars grid is empty")
    func emptyAvatarGrid() async throws {
        urlSession.shouldFetchEmptyAvatarsGrid = true
        await viewModel.fetchAvatars()
        let view = AvatarPickerView(avatarPickerModel: viewModel, onLogout: {})
            .forTests()
        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @Test
    func noAvatarSelected() async throws {
        await viewModel.fetchAvatars()
        if let selectedAvatar = viewModel.grid.selectedAvatar {
            _ = await viewModel.delete(selectedAvatar)
        }
        let view = AvatarPickerView(avatarPickerModel: viewModel, onLogout: {})
            .forTests()

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @Test("AvatarPickerView displays correctly if the fetching happens when the grid is empty)", arguments: [true, false])
    func avatarFetchingWhenGirdIsEmpty(isSuccess: Bool) async throws {
        urlSession.returnErrorCode = isSuccess ? nil : 400
        await viewModel.fetchAvatars()
        let view = AvatarPickerView(avatarPickerModel: viewModel, onLogout: {})
            .forTests()

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ],
            testName: "avatarFetchingWhenGirdIsEmpty-\(isSuccess ? "success" : "error")"
        )
    }

    @Test("AvatarPickerView displays correctly if the fetching happens when the grid is NOT empty)", arguments: [true, false])
    func avatarFetchingWhenGirdIsNotEmpty(isSuccess: Bool) async throws {
        // First attempt is successful and we fill the grid.
        await viewModel.fetchAvatars()

        urlSession.returnErrorCode = isSuccess ? nil : 400

        // Second attempt depends on the `isSuccess` flag.
        await viewModel.fetchAvatars()

        let view = AvatarPickerView(avatarPickerModel: viewModel, onLogout: {})
            .forTests()

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

extension View {
    fileprivate func forTests() -> some View {
        self.environment(\.analytics, Analytics.test)
            .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0, height: ViewImageConfig.iPhone13Pro.size?.height ?? 0)
            .transaction { $0.animation = nil }
    }
}
