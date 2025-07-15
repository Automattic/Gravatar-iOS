import Foundation
@testable import GravatarApp
import SnapshotTesting
import SwiftUICore
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct ContentLoadingErrorViewTests {
    @MainActor
    @Test("ContentLoadingErrorView for avatars displayed correctly")
    func contentLoadingErrorViewAvatars() async throws {
        let view =
            VStack(spacing: 0) {
                ContentLoadingErrorView.avatars {}
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0)
                    .padding()
            }
            .background(Color(uiColor: .systemBackground))

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }
}
