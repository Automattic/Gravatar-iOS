import Foundation
@testable import GravatarApp
import SnapshotTesting
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
@MainActor
struct ShareViewTests {
    init() async throws {
        UserDefaults.testUserDefaults.removePersistentDomain(forName: UserDefaults.testSuiteName)
    }

    @Test
    func shareContent() async throws {
        let view = ShareContentView(viewModel: .init(
            userSession: .init(profile: .full, accessToken: "", context: .testContext),
            userDefaults: .testUserDefaults
        ))
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @Test
    func shareView() async throws {
        let view = ShareView(
            viewModel: .init(userSession: .init(profile: .full, accessToken: "", context: .testContext), userDefaults: .testUserDefaults),
            forceRefreshAvatar: .constant(false)
        )
        .fullScreenFrame()

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @Test("Snapshot of share view when the profile is empty")
    func shareViewEmpty() async throws {
        let view = ShareView(
            viewModel: ShareViewModel(userSession: UserSession(
                profile: .clean,
                accessToken: "",
                context: .testContext
            ), userDefaults: .testUserDefaults),
            forceRefreshAvatar: .constant(false)
        )
        .fullScreenFrame()

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }
}
