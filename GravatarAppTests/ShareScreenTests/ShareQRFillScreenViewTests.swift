@testable import GravatarApp
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
@MainActor
struct ShareQRFillScreenViewTests {
    @Test("Snapshot of QR view full screen")
    func shareQRFullScreenView() async throws {
        let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")

        let view = GeometryReader { geometry in
            ShareQRFullScreenView(
                presentFullScreen: .constant(true),
                topPadding: geometry.safeAreaInsets.top,
                imageURL: imageURL,
                forceRefresh: .constant(false),
                windowWidth: geometry.size.width,
                qrImage: { QRGenerator.fallbakImage }
            )
        }
        .background(Color.secondary)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .device(config: .iPhone13)),
                .testStrategy(userInterfaceStyle: .dark, layout: .device(config: .iPhone13)),
            ]
        )
    }
}
