import Analytics

enum MainMenuEvents {
    static let visitProfileTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "mainmenu_visit_profile_button_tapped")
    static let shareProfileTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "mainmenu_share_profile_button_tapped")
    static let visitGravatarComTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "mainmenu_visit_gravatarcom_button_tapped")
    static let aboutTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "mainmenu_about_button_tapped")
    static let signOutTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "mainmenu_signout_button_tapped")
}
