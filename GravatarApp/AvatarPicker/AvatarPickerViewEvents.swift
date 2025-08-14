import Analytics
import Foundation

enum AvatarPickerViewEvents {
    static let screenView: AnalyticsEvent = AppEvent.screenView(screen: .avatars)
    static let screenLeave: AnalyticsEvent = AppEvent.screenLeave(screen: .avatars)
    static let mainMenuTapped: AnalyticsEvent = AppEvent.mainMenuTapped(screen: .avatars)

    static let avatarsGridItemTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "avatars_grid_item_tapped")
    static let avatarsCameraButtonTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "avatars_camera_button_tapped")
    static let avatarsPhotosButtonTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "avatars_photos_button_tapped")
    static let avatarsAIButtonTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "avatars_ai_button_tapped")

    static let avatarsActionSelected: AnalyticsEvent = CommonAnalyticsEvent(name: "avatar_action_select")
    static let avatarsActionShare: AnalyticsEvent = CommonAnalyticsEvent(name: "avatar_action_share")
    static let avatarsActionDelete: AnalyticsEvent = CommonAnalyticsEvent(name: "avatar_action_delete")
}
