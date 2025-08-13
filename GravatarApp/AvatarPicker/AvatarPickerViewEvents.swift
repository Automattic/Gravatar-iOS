import Analytics
import Foundation

enum AvatarPickerViewEvents {
    static let screen: String = "avatars"
    static let screenView: AnalyticsEvent = AppEvent.screenView(screen: .avatars)
    static let screenLeave: AnalyticsEvent = AppEvent.screenLeave(screen: .avatars)
    static let mainMenuTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "mainmenu_tapped", properties: MenuEventProperties(screen: .avatars))
    static let tabGravatarTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "tab_gravatar_tapped")
    static let tabProfileTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "tab_profile_tapped")
    static let tabQRTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "tab_qr_tapped")
    static let avatarsGridItemTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "avatars_grid_item_tapped")
    static let avatarsCameraButtonTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "avatars_camera_button_tapped")
    static let avatarsPhotosButtonTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "avatars_photos_button_tapped")
    static let avatarsAIButtonTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "avatars_ai_button_tapped")
}

private struct MenuEventProperties: Encodable & Sendable {
    let screen: AppEvent.Screens
}
