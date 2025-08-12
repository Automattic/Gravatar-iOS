import Analytics
import Foundation

struct ScreenEventProperties: Encodable, Sendable {
    let screen: String
}

struct ScreenViewEvent: AnalyticsEvent {
    let name: String
    let properties: EventProperties?

    init(screen: String) {
        self.name = "screen_view"
        self.properties = ScreenEventProperties(screen: screen)
    }
}

struct ScreenLeaveEvent: AnalyticsEvent {
    let name: String
    let properties: EventProperties?

    init(screen: String) {
        self.name = "screen_leave"
        self.properties = ScreenEventProperties(screen: screen)
    }
}
