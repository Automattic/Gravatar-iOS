import Analytics
import Foundation

enum WelcomeScreenEvent {
    static let authButtonPressed: AnalyticsEvent = AuthButtonPressed()
    static let authSuccess: AnalyticsEvent = AuthSuccess()
    static func authFailed(with error: String) -> AnalyticsEvent {
        AuthFailed(properties: AuthFailed.Properties(error: error))
    }
}

private struct AuthButtonPressed: AnalyticsEvent {
    let name: String = "auth_button_pressed"
    let properties: EventProperties? = nil
}

private struct AuthSuccess: AnalyticsEvent {
    let name: String = "auth_success"
    let properties: EventProperties? = nil
}

private struct AuthFailed: AnalyticsEvent {
    struct Properties: Encodable, Sendable {
        let error: String
    }

    var name: String = "auth_failed"
    var properties: EventProperties?
}
