import Analytics
import Foundation

enum AppEvent {
    enum Screens: String, Encodable {
        case login
        case avatars
        case profile
        case qr
        case qrFullScreen = "qr_full_screen"
        case about
    }

    static func screenView(screen: AppEvent.Screens) -> AnalyticsEvent {
        CommonAnalyticsEvent(name: "screen_view", properties: ScreenEventProperties(screen: screen))
    }

    static func screenLeave(screen: AppEvent.Screens) -> AnalyticsEvent {
        CommonAnalyticsEvent(name: "screen_leave", properties: ScreenEventProperties(screen: screen))
    }
}

private struct ScreenEventProperties: Encodable, Sendable {
    let screen: AppEvent.Screens
}
