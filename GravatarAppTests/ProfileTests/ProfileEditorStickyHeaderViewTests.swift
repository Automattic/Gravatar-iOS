import Foundation
import Gravatar
@testable import GravatarApp
import SnapshotTesting
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
@MainActor
struct ProfileEditorStickyHeaderViewTests {
    @Test("The view displays correctly when the profile data is full or missing", arguments: [true, false])
    func header(hasMissingData: Bool) async throws {
        let profile: Profile = hasMissingData ? .with(location: "", jobTitle: "", company: "") : .full
        let view = ProfileEditorStickyHeaderView(
            profile: profile,
            opacity: 1,
            safeAreaInsets: .zero,
            imageURL: URL(string: profile.avatarUrl),
            forceRefresh: .constant(false)
        )
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ],
            testName: "profileEditorStickyHeader_\(hasMissingData ? "missing_data" : "full_data")"
        )
    }
}
