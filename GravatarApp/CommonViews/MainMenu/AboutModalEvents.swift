import Analytics

enum AboutModalEvents {
    static let screenView: AnalyticsEvent = AppEvent.screenView(screen: .about)
    static let screenLeave: AnalyticsEvent = AppEvent.screenLeave(screen: .about)

    static let supportLinkTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "about_support_link_button_tapped")
    static let supportEmailTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "about_support_email_button_tapped")
    static let tosTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "about_tos_button_tapped")
    static let privacyPolicyTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "about_privacy_policy_button_tapped")
    static let deleteAccountTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "about_delete_account_button_tapped")
    static let deleteAccountWarningAccepted: AnalyticsEvent = CommonAnalyticsEvent(name: "about_delete_account_warning_accepted")
    static let deleteAccountWarningCancelled: AnalyticsEvent = CommonAnalyticsEvent(name: "about_delete_account_warning_cancelled")
}
