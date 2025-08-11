import Analytics
import Foundation

enum WelcomeScreenEvent {
    static let loginButtonPressed: AnalyticsEvent = LoginButtonPressed()

    static let oauthStart: AnalyticsEvent = OAuthStart()
    static let oauthSuccess: AnalyticsEvent = OAuthSuccess()
    static func oauthError(error: String) -> AnalyticsEvent {
        OAuthError(properties: OAuthError.Properties(error: error))
    }

    static let profileFetchStart: AnalyticsEvent = ProfileFetchStart()
    static let profileFetchSuccess: AnalyticsEvent = ProfileFetchSuccess()
    static func profileFetchError(error: String) -> AnalyticsEvent {
        ProfileFetchError(properties: ProfileFetchError.Properties(error: error))
    }
}

private struct LoginButtonPressed: AnalyticsEvent {
    let name: String = "login_button_pressed"
    let properties: EventProperties? = nil
}

private struct OAuthStart: AnalyticsEvent {
    let name: String = "oauth_start"
    let properties: EventProperties? = nil
}

private struct OAuthSuccess: AnalyticsEvent {
    let name: String = "oauth_success"
    let properties: EventProperties? = nil
}

private struct OAuthError: AnalyticsEvent {
    struct Properties: Encodable, Sendable {
        let error: String
    }

    let name: String = "oauth_error"
    let properties: EventProperties?
}

private struct ProfileFetchStart: AnalyticsEvent {
    let name: String = "profile_fetch_start"
    let properties: EventProperties? = nil
}

private struct ProfileFetchSuccess: AnalyticsEvent {
    let name: String = "profile_fetch_success"
    let properties: EventProperties? = nil
}

private struct ProfileFetchError: AnalyticsEvent {
    struct Properties: Encodable, Sendable {
        let error: String
    }

    let name: String = "profile_fetch_error"
    let properties: EventProperties?
}
