import AutomatticTracksEvents
import AutomatticTracksModel
import Foundation
import OSLog

public actor Analytics {
    public static let shared = Analytics()
    private static var pushEventsToRemote: Bool = true

    private let tracker: Tracker
    private let logger = Logger(subsystem: "com.gravatar", category: "gravatar.analytics")
    private var loggedInUserId: String?
    private let userUUIDStorage: UserUUIDStorage

    init(tracker: Tracker? = nil, userUUIDStorage: UserUUIDStorage = UserDefaults.standard) {
        self.tracker = tracker ?? TracksService(contextManager: TracksContextManager())
        self.userUUIDStorage = userUUIDStorage
        self.tracker.configure()
        self.tracker.setUserName(nil, userUUIDStorage: userUUIDStorage)

        TracksLogging.delegate = LoggingDelegate()

        Task {
            await updateUserProperties()
        }
    }

    public nonisolated
    func track(_ event: AnalyticsEvent) {
        let properties = event.dictionaryProperties ?? [:]

        if Self.pushEventsToRemote {
            tracker.track(event.name, withCustomProperties: properties)
        }

        #if DEBUG
        let isMockTracker = String(describing: type(of: tracker)).contains("TrackerMock")
        let trackingText = !Self.pushEventsToRemote || isMockTracker ? " (Locally)" : ""
        logger.debug("🔹 Tracking\(trackingText): \(event.name); properties: \(event.jsonStringProperties ?? "{}")")
        #endif
    }

    public func setUserName(_ userName: String?) {
        loggedInUserId = userName
        tracker.setUserName(userName, userUUIDStorage: userUUIDStorage)

        updateUserProperties()
    }

    public static func setPushEventsToRemote(_ pushEventsToRemote: Bool) {
        Self.pushEventsToRemote = pushEventsToRemote
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
