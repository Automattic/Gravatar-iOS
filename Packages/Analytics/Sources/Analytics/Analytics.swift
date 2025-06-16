import Foundation
import AutomatticTracksEvents
import AutomatticTracksModel
import OSLog

public class Analytics {
    private let tracker: Tracker
    private let logger = Logger(subsystem: "com.gravatar", category: "gravatar.analytics")
    private var loggedInUserId: String?

    public init(tracker: Tracker? = nil) {
        self.tracker = tracker ?? TracksService(contextManager: TracksContextManager())
        self.tracker.configure()

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

    public func setUserId(_ userId: String?) {
        loggedInUserId = userId
        updateUserProperties()
    }

    private var defaultProperties: [String: AnyHashable] {
        [
            "user_is_logged_in": loggedInUserId != nil,
        ]
    }
}

private extension Analytics {
    func updateUserProperties() {
        defaultProperties.forEach { (key: String, value: AnyHashable) in
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
