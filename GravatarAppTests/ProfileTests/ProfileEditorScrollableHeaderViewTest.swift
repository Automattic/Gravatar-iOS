import Gravatar
@testable import GravatarApp
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
@MainActor
struct ProfileEditorScrollableHeaderViewTest {
    @Test("Profile header view displays correctly with normal content")
    func profileEditorScrollableHeader() async throws {
        let view = ProfileEditorScrollableHeaderView(
            profile: .full,
            topPadding: 0,
            imageURL: nil,
            forceRefresh: .constant(false),
            onProfileButtonTapped: {}
        )
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

    @Test("Profile header view displays correctly with long content")
    func profileEditorHeaderWithLongText() async throws {
        let profile: Profile = .with(
            displayName: "Very long display name that goes over multiple lines",
            jobTitle: "Very long job title that goes over multiple lines"
        )

        let view = ZStack(alignment: .top) {
            ProfileEditorScrollableHeaderView(
                profile: profile,
                topPadding: 0,
                imageURL: nil,
                forceRefresh: .constant(false),
                onProfileButtonTapped: {}
            )
        }
        .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0, height: 350)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }
}
