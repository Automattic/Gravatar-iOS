@testable import Analytics
import Foundation
@testable import GravatarApp
import SwiftData
import Testing

@MainActor
struct CrashLoggerTests {
    let modelContainer = ModelContext.testContainer

    @Test("Crash logging is enabled by default")
    func defaultEnablesCrashLogging() async throws {
        let userDefaults = UserDefaults.testUserDefaults(named: #function)
        let spyLogging = CrashLoggingMock()

        let logger = CrashLogger(crashLogging: spyLogging, context: modelContainer.mainContext, userDefaults: userDefaults)

        logger.start()

        #expect(spyLogging.isEnabled)
        userDefaults.removePersistentDomain(forName: #function)
    }

    @Test("Crash logging is disabled if user has opted out")
    func optedOutDoesNotEnableCrashLogging() async throws {
        let userDefaults = UserDefaults.testUserDefaults(named: #function)
        let settings = PrivacySettingsUserSelection(userDefaults: userDefaults)
        settings.shareCrashReports = false

        let spyLogging = CrashLoggingMock()
        let logger = CrashLogger(crashLogging: spyLogging, context: modelContainer.mainContext, userDefaults: userDefaults)
        logger.start()

        #expect(!spyLogging.isEnabled)
        userDefaults.removePersistentDomain(forName: #function)
    }

    @Test("Crash logging gets disabled when user opts out")
    func crashLoggingGetsDisabled() async throws {
        let userDefaults = UserDefaults.testUserDefaults(named: #function)
        let trackerMock = TrackerMock()
        let analytics = Analytics(tracker: trackerMock, userUUIDStorage: UserUUIDStorageMock())
        let settings = PrivacySettingsUserSelection(userDefaults: userDefaults, analytics: analytics)

        let spyLogging = CrashLoggingMock()
        let logger = CrashLogger(crashLogging: spyLogging, context: modelContainer.mainContext, userDefaults: userDefaults)
        logger.start()

        #expect(spyLogging.isEnabled)

        settings.shareCrashReports = false
        let event = trackerMock.trackedEvents.first
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(event?.name == PrivacySettingsEvents.shareCrashReportsToggled(enabled: false).name)
        #expect((event?.properties["is_on"] as? Bool) == false)
        logger.optOutChanged()

        #expect(!spyLogging.isEnabled)
        userDefaults.removePersistentDomain(forName: #function)
    }

    @Test("Crash logging gets enabled when user opts in")
    func crashLoggingGetsEnabled() async throws {
        let userDefaults = UserDefaults.testUserDefaults(named: #function)
        let trackerMock = TrackerMock()
        let analytics = Analytics(tracker: trackerMock, userUUIDStorage: UserUUIDStorageMock())
        let settings = PrivacySettingsUserSelection(userDefaults: userDefaults, analytics: analytics)
        settings.shareCrashReports = false

        let spyLogging = CrashLoggingMock()
        let logger = CrashLogger(crashLogging: spyLogging, context: modelContainer.mainContext, userDefaults: userDefaults)
        logger.start()

        #expect(!spyLogging.isEnabled)

        // Reset trackedEvents
        trackerMock.trackedEvents.removeAll()

        settings.shareCrashReports = true
        let event = trackerMock.trackedEvents.first
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(event?.name == PrivacySettingsEvents.shareCrashReportsToggled(enabled: true).name)
        #expect((event?.properties["is_on"] as? Bool) == true)
        logger.optOutChanged()

        #expect(spyLogging.isEnabled)
        userDefaults.removePersistentDomain(forName: #function)
    }
    
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
