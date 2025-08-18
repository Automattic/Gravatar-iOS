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
        let settings = PrivacySettingsUserSelection(userDefaults: userDefaults)

        let spyLogging = CrashLoggingMock()
        let logger = CrashLogger(crashLogging: spyLogging, context: modelContainer.mainContext, userDefaults: userDefaults)
        logger.start()

        #expect(spyLogging.isEnabled)

        settings.shareCrashReports = false
        logger.optOutChanged()

        #expect(!spyLogging.isEnabled)
        userDefaults.removePersistentDomain(forName: #function)
    }

    @Test("Crash logging gets enabled when user opts in")
    func crashLoggingGetsEnabled() async throws {
        let userDefaults = UserDefaults.testUserDefaults(named: #function)
        let settings = PrivacySettingsUserSelection(userDefaults: userDefaults)
        settings.shareCrashReports = false

        let spyLogging = CrashLoggingMock()
        let logger = CrashLogger(crashLogging: spyLogging, context: modelContainer.mainContext, userDefaults: userDefaults)
        logger.start()

        #expect(!spyLogging.isEnabled)

        settings.shareCrashReports = true
        logger.optOutChanged()

        #expect(spyLogging.isEnabled)
        userDefaults.removePersistentDomain(forName: #function)
    }
}
