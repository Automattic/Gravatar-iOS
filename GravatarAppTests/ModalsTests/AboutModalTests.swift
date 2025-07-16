import Foundation
@testable import GravatarApp
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
@MainActor
struct AboutModalTests {
    init() async throws {
        setenv("SNAPSHOT_TESTING", "1", 1)
    }

    @Test()
    func AboutModal() async throws {
        let modalManager = ModalPresentationManager()
        modalManager.present {
            AboutView()
        }

        let view = Color.clear
            .modalPresentation(manager: modalManager)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }
}

extension View {
    func fullScreenFrame() -> some View {
        self.frame(width: ViewImageConfig.iPhone13.size?.width ?? 0, height: ViewImageConfig.iPhone13.size?.height ?? 0)
    }
}
