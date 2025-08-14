import Analytics

enum QRScreenEvents {
    static let screenView: AnalyticsEvent = AppEvent.screenView(screen: .qr)
    static let screenLeave: AnalyticsEvent = AppEvent.screenLeave(screen: .qr)
    static let mainMenuTapped: AnalyticsEvent = AppEvent.mainMenuTapped(screen: .qr)

    static let headerShareTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "qr_header_share_tapped")
    static let headerExpandTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "qr_header_expand_tapped")
    static let previewButtonTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "qr_preview_tapped")
    static let privateInfoButtonTapped: AnalyticsEvent = CommonAnalyticsEvent(name: "qr_private_contact_info_button_tapped")

    static func fieldToggled(isOn: Bool, field: FieldToggle.Field) -> AnalyticsEvent {
        CommonAnalyticsEvent(name: "qr_field_toggled", properties: FieldToggle(isOn: isOn, field: field.rawValue))
    }
}

extension QRScreenEvents {
    struct FieldToggle: EventProperties {
        enum Field {
            case email
            case phone
            case name
            case location
            case jobTitle
            case company
            case aboutMe
            case profileURL
            case verifiedAccount(String)
        }
        let isOn: Bool
        let field: String
    }
}

extension QRScreenEvents.FieldToggle.Field {
    fileprivate var rawValue: String {
        switch self {
        case .email, .phone, .name, .company, .location:
            return String(describing: self)
        case .jobTitle: 
            return "job_title"
        case .aboutMe: 
            return "about_me"
        case .profileURL: 
            return "profile_url"
        case .verifiedAccount(let service):
            return "verified_account_\(service)"
        }
    }
}
