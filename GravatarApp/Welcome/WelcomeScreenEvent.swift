import Analytics
import Foundation

enum WelcomeScreenEvent {
    static let loginButtonTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "login_button_tapped")

    static let oauthStart: AnalyticsEvent = CommonAnalyticsEvent(name: "oauth_start")
    static let oauthCancelled: AnalyticsEvent = CommonAnalyticsEvent(name: "oauth_cancelled")
    static let oauthSuccess: AnalyticsEvent = CommonAnalyticsEvent(name: "oauth_success")
    static let profileFetchStart: AnalyticsEvent = CommonAnalyticsEvent(name: "profile_fetch_start")
    static let profileFetchSuccess: AnalyticsEvent = CommonAnalyticsEvent(name: "profile_fetch_success")
    static let tabGravatarTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "tab_gravatar_tapped")
    static let tabProfileTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "tab_profile_tapped")
    static let tabQRTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "tab_qr_tapped")
}

private struct ErrorEventProperties: EventProperties {
    let error: String
}
