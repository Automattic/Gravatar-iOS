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
        ScreenView(properties: ScreenView.Properties(screen: screen))
    }

    static func screenLeave(screen: AppEvent.Screens) -> AnalyticsEvent {
        ScreenLeave(properties: ScreenView.Properties(screen: screen))
    }
}

private struct ScreenView: AnalyticsEvent {
    struct Properties: EventProperties {
        let screen: AppEvent.Screens
    }

    let name: String = "screen_view"
    let properties: EventProperties?
}

private struct ScreenLeave: AnalyticsEvent {
    struct Properties: EventProperties {
        let screen: AppEvent.Screens
    }

    let name: String = "screen_leave"
    let properties: EventProperties?
}
