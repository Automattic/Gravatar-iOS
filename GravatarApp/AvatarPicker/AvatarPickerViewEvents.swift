import Analytics
import Foundation

struct MenuEventProperties: Encodable & Sendable {
    let screen: String
}

enum AvatarPickerViewEvents {
    static let screen: String = "avatars"
    static let screenView: AnalyticsEvent = ScreenViewEvent(screen: Self.screen)
    static let screenLeave: AnalyticsEvent = ScreenLeaveEvent(screen: Self.screen)
    static let mainMenuTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "mainmenu_tapped", properties: MenuEventProperties(screen: Self.screen))
    static let tabGravatarTapped: AnalyticsEvent = NoPropertyAnalyticsEvent(name: "tab_gravatar_tapped")
    static let tabProfileTapped: AnalyticsEvent = NoPropertyAnalyticsEvent(name: "tab_profile_tapped")
    static let tabQRTapped: AnalyticsEvent = NoPropertyAnalyticsEvent(name: "tab_qr_tapped")
    static let avatarsGridItemTapped: AnalyticsEvent = NoPropertyAnalyticsEvent(name: "avatars_grid_item_tapped")
    static let avatarsCameraButtonTapped: AnalyticsEvent = NoPropertyAnalyticsEvent(name: "avatars_camera_button_tapped")
    static let avatarsPhotosButtonTapped: AnalyticsEvent = NoPropertyAnalyticsEvent(name: "avatars_photos_button_tapped")
    static let avatarsAIButtonTapped: AnalyticsEvent = NoPropertyAnalyticsEvent(name: "avatars_ai_button_tapped")
}
