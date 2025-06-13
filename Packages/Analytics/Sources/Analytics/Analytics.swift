import Foundation
import AutomatticTracks
import OSLog

public protocol Tracker {
    func track(_ name: String, withCustomProperties: [String: AnyHashable])
    func setUserProperty(_ value: AnyHashable, for key: String)
    func configure()
}

extension TracksService: Tracker {
    private enum Config {
        static let prefix = "gravatar_ios"
        static let userKey = "gravatar:user_id"
        static let platform = "gravatar"
    }

    public func track(_ name: String, withCustomProperties: [String : AnyHashable]) {
        trackEventName(name, withCustomProperties: withCustomProperties)
    }

    public func setUserProperty(_ value: AnyHashable, for key: String) {
        userProperties[key] = value
    }

    public func configure() {
        platform = Config.platform
        eventNamePrefix = Config.prefix
        authenticatedUserTypeKey = Config.userKey
    }
}

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
