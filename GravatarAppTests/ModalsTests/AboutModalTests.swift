import Analytics
import Foundation
@testable import GravatarApp
import SnapshotTesting
import SwiftUI
import Testing

// Mock Bundle for testing that provides consistent version info
class MockBundle: Bundle {
    override var infoDictionary: [String: Any]? {
        [
            "CFBundleShortVersionString": "1.0.0",
        ]
    }
}

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
@MainActor
struct AboutModalTests {
    @Test()
    func AboutModal() async throws {
        let modalManager = ModalPresentationManager()

        // Create a mock bundle with version info for testing
        let mockBundle = MockBundle()

        modalManager.present {
            AboutView(bundle: mockBundle)
                .environment(\.analytics, Analytics.test)
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
