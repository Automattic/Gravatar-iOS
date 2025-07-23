@testable import GravatarApp
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
@MainActor
struct PrivateInformationAlertViewTests {
    @Test
    func privateInfoAlertSnapshot() async throws {
        let modalManager = ModalPresentationManager()
        modalManager.present {
            PrivateInformationAlertView(onDismiss: {})
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
