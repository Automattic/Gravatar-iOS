import Analytics
import SwiftUI

final class PrivacySettingsUserSelection: ObservableObject {
    private let userDefaults: UserDefaults
    let analytics: Analytics

    init(userDefaults: UserDefaults = .standard, analytics: Analytics = .shared) {
        self.userDefaults = userDefaults
        self.analytics = analytics
        shareAnalytics = userDefaults.bool(forKey: .analyticsKey, default: true)
        shareCrashReports = userDefaults.bool(forKey: .crashReportKey, default: true)
    }

    @Published var shareAnalytics: Bool {
        didSet {
            // If it's changing from off -> on then this one won't be sent.
            analytics.track(PrivacySettingsEvents.shareAnalyticsToggled(enabled: shareAnalytics))
            userDefaults.set(shareAnalytics, forKey: .analyticsKey)
            Analytics.setPushEventsToRemote(shareAnalytics)
            // If it's changing from on -> off then this one won't be sent.
            analytics.track(PrivacySettingsEvents.shareAnalyticsToggled(enabled: shareAnalytics))
        }
    }

    @Published var shareCrashReports: Bool {
        didSet {
            analytics.track(PrivacySettingsEvents.shareCrashReportsToggled(enabled: shareCrashReports))
            userDefaults.set(shareCrashReports, forKey: .crashReportKey)
            NotificationCenter.default.post(name: .crashLoggerOptOutChanged, object: nil)
        }
    }
}

extension String {
    fileprivate static let analyticsKey = "AnalyticsKey"
    fileprivate static let crashReportKey = "CrashReportKey"
}
