import Gravatar
@testable import GravatarApp
import SnapshotTesting
import SwiftUI
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
            safeAreaInsets: .init(top: 0, leading: 0, bottom: 0, trailing: 0),
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

    @Test("Profile collapsed header displays correctly with long content")
    func profileCollapsedHeaderWithLongText() async throws {
        let profile: Profile = .with(
            displayName: "Very long display name that goes over multiple lines",
            jobTitle: "Very long job title that goes over multiple lines"
        )

        let view = AnimatedHeaderScrollView(animationBehavior: .automatic) { _ in
            ProfileEditorStickyHeaderView(
                profile: profile,
                opacity: 1,
                safeAreaInsets: .init(top: 8, leading: 0, bottom: 0, trailing: 0),
                imageURL: URL(string: profile.avatarUrl),
                forceRefresh: .constant(false)
            )
        } stickyHeader: { _, _ in
            EmptyView()
        } content: {
            Text("Content")
        } buttonMenuItems: {
            EmptyView()
        } onRefresh: {}
            .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0, height: 200)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }
}
