import Foundation
import AutomatticTracksEvents
import OSLog

@MainActor
public class Analytics {
    private let tracker: Tracker
    private let logger = Logger(subsystem: "com.gravatar", category: "gravatar.analytics")
    private var loggedInUserId: String?

    public init(tracker: Tracker? = nil) {
        self.tracker = tracker ?? TracksService(contextManager: TracksContextManager())
        self.tracker.configure()

        updateUserProperties()
    }

    public func track(_ event: AnalyticsEvent) {
        let properties = event.jsonProperties ?? [:]
        tracker.track(event.name, withCustomProperties: properties)
        #if DEBUG
        logger.debug("➥ Tracking: \(event.name); properties: \(properties)")
        #endif
    }

    public func setUserId(_ userId: String?) {
        loggedInUserId = userId
        updateUserProperties()
    }

    private var defaultProperties: [String: AnyHashable] {
        [
            "user_is_logged_in": loggedInUserId != nil,

            // Accessibility
            "is_rtl_language": UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft,
            "dynamic_font_size_category": UIApplication.shared.preferredContentSizeCategory.rawValue
        ]
    }
}

private extension Analytics {
    func updateUserProperties() {
        defaultProperties.forEach { (key: String, value: AnyHashable) in
            self.tracker.setUserProperty(value, for: key)
        }
    }
}
