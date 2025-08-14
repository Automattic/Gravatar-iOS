import Analytics
import Foundation

enum ProfileEditorEvents {
    static let screenView: AnalyticsEvent = AppEvent.screenView(screen: .profile)
    static let screenLeave: AnalyticsEvent = AppEvent.screenLeave(screen: .profile)
    static let mainMenuTapped: AnalyticsEvent = AppEvent.mainMenuTapped(screen: .profile)

    static let profileHeaderLinkTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "profile_headerlink_tapped")
    static let profileCancelChangesTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "profile_cancel_changes_tapped")
    static let profileSaveChangesTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "profile_save_changes_tapped")
}
