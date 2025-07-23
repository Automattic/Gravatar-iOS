@testable import GravatarApp
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
@MainActor
struct ShareHeaderViewTests {
    @Test
    func shareHeaderView() async throws {
        let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")
        let width = ViewImageConfig.iPhone13.size?.width ?? 0
        let view = ScrollView {
            ShareHeaderView(
                profile: .testProfile,
                qrImage: { Image(systemName: "qrcode").resizable().foregroundStyle(.black).padding().background(Color.white) },
                topPadding: 16,
                imageURL: imageURL,
                forceRefresh: .constant(false),
                windowWidth: .constant(width)
            )
        }
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
