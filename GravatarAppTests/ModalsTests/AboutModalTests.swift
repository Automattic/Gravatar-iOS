import Foundation
@testable import GravatarApp
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
@MainActor
struct AboutModalTests {
    @Test()
    func AboutModal() async throws {
        let modalManager = ModalPresentationManager()
        modalManager.present {
            AboutView()
        }

        let view = Color.clear
            .modalPresentation(manager: modalManager)
            .modalBackground(Color(uiColor: .secondarySystemBackground))

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }
}
