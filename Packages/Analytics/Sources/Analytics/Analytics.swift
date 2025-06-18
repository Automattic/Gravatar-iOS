import AutomatticTracksEvents
import AutomatticTracksModel
import Foundation
import OSLog

public class Analytics {
    private let tracker: Tracker
    private let logger = Logger(subsystem: "com.gravatar", category: "gravatar.analytics")
    private var loggedInUserId: String?
    private let userUUIDStorage: UserUUIDStorage

    public init(tracker: Tracker? = nil, userUUIDStorage: UserUUIDStorage = UserDefaults.standard) {
        self.tracker = tracker ?? TracksService(contextManager: TracksContextManager())
        self.userUUIDStorage = userUUIDStorage
        self.tracker.configure()
        self.tracker.setUserID(nil, userUUIDStorage: userUUIDStorage)

        updateUserProperties()
        TracksLogging.delegate = LoggingDelegate()
    }

    public func track(_ event: AnalyticsEvent) {
        let properties = event.jsonProperties ?? [:]
        tracker.track(event.name, withCustomProperties: properties)
        #if DEBUG
        logger.debug("🔹 Tracking: \(event.name); properties: \(properties)")
        #endif
    }

    public func setUserID(_ userID: String?) {
        loggedInUserId = userID
        tracker.setUserID(userID, userUUIDStorage: userUUIDStorage)

        updateUserProperties()
    }

    private var defaultProperties: [String: AnyHashable] {
        [
            "user_is_logged_in": loggedInUserId != nil,
        ]
    }
}

extension Analytics {
    private func updateUserProperties() {
        for (key, value) in defaultProperties {
            tracker.setUserProperty(value, for: key)
        }
    }
}

private class LoggingDelegate: NSObject, TracksLoggingDelegate {
    private let logger = Logger(subsystem: "com.tracks", category: "gravatar.analytics.logger_delegate")

    func logError(_ str: String) {
        logger.error("‼️ \(str)")
    }

    func logWarning(_ str: String) {
        logger.warning("⚠️ \(str)")
    }

    func logInfo(_ str: String) {
        logger.info("🔸 \(str)")
    }

    func logDebug(_ str: String) {
        logger.debug("🔸 \(str)")
    }

    func logVerbose(_ str: String) {
        logger.log("🔸 \(str)")
    }
}
