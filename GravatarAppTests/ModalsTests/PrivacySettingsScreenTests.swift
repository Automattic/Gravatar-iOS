import Analytics
import Foundation
@testable import GravatarApp
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
@MainActor
struct PrivacySettingsScreenTests {
    @Test("Snapshot test of Privacy Settings")
    func privacySettingsSnapshot() async throws {
        let view = NavigationStack {
            ZStack {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                PrivacySettingsScreen(isPresented: .constant(true), userDefaults: .testUserDefaults)
            }
        }

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @Test("Snapshot test of Privacy Settings switches off")
    func privacySettingsSnapshotSwitchesOff() async throws {
        let userDefaults = UserDefaults.testUserDefaults(named: "privacySettingsSwitchesOff")
        userDefaults.set(false, forKey: "AnalyticsKey")
        userDefaults.set(false, forKey: "CrashReportKey")
        let view = NavigationStack {
            ZStack {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                PrivacySettingsScreen(isPresented: .constant(true), userDefaults: userDefaults)
            }
        }

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }
}
