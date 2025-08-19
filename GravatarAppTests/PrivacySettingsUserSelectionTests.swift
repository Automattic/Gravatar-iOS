@testable import Analytics
import Foundation
@testable import GravatarApp
import SwiftData
import Testing

struct PrivacySettingsUserSelectionTests {
    @Test("Toggle event is sent when sharing analytics is toggled", arguments: [false, true])
    func toggleShareAnalytics(isOn: Bool) async throws {
        let trackerMock = TrackerMock()
        let userDefaults = UserDefaults.testUserDefaults(named: #function)
        let analytics = Analytics(tracker: trackerMock, userUUIDStorage: UserUUIDStorageMock())
        let settings = PrivacySettingsUserSelection(userDefaults: userDefaults, analytics: analytics)
        settings.shareAnalytics = !isOn

        // Reset events
        trackerMock.trackedEvents.removeAll()

        settings.shareAnalytics = isOn

        let event = trackerMock.trackedEvents.first
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(event?.name == PrivacySettingsEvents.shareAnalyticsToggled(enabled: isOn).name)
        #expect((event?.properties["is_on"] as? Bool) == isOn)

        userDefaults.removePersistentDomain(forName: #function)
    }

    @Test("Analytics event is sent or not sent according to the toggle", arguments: [false, true])
    func toggleShareAnalyticsIsRespectedWhenSendingTheEvent(isOn: Bool) async throws {
        let trackerMock = TrackerMock()
        let userDefaults = UserDefaults.testUserDefaults(named: #function)
        let analytics = Analytics(tracker: trackerMock, userUUIDStorage: UserUUIDStorageMock())
        let settings = PrivacySettingsUserSelection(userDefaults: userDefaults, analytics: analytics)
        settings.shareAnalytics = isOn

        // Reset events
        trackerMock.trackedEvents.removeAll()

        analytics.track(CommonAnalyticsEvent(name: "test_event"))

        if isOn {
            #expect(trackerMock.trackedEvents.count == 1)
            #expect(trackerMock.trackedEvents.first?.name == "test_event")
        } else {
            #expect(trackerMock.trackedEvents.count == 0)
        }

        userDefaults.removePersistentDomain(forName: #function)
    }
}
