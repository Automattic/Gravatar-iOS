@testable import GravatarApp
import SnapshotTesting
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
@MainActor
struct SaveToolbarTests {
    let viewModel = EditProfileViewModel(
        userSession: UserSession(
            profile: .full,
            accessToken: "testToken",
            context: .testContext
        ),
        urlSession: URLSessionMock()
    )

    @Test("Save Profile Toolbar initial state")
    func saveToolbarSnapshot() async throws {
        let view = SaveToolbar(viewModel: viewModel)
            .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @Test("Save Profile Toolbar on saving state")
    func saveToolbarSnapshotSaving() async throws {
        let view = SaveToolbar(viewModel: viewModel)
            .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0)

        viewModel.isSaving = true

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }
}
