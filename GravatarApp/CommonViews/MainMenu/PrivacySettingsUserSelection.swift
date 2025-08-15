import SwiftUI
import Analytics

final class PrivacySettingsUserSelection: ObservableObject {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        shareAnalytics = userDefaults.bool(forKey: .analyticsKey, default: true)
        shareCrashReports = userDefaults.bool(forKey: .crashReportKey, default: true)
    }

    @Published var shareAnalytics: Bool {
        didSet {
            userDefaults.set(shareAnalytics, forKey: .analyticsKey)
            Analytics.setPushEventsToRemote(shareAnalytics)
        }
    }

    @Published var shareCrashReports: Bool {
        didSet {
            userDefaults.set(shareCrashReports, forKey: .crashReportKey)
        }
    }
}

private extension String {
    static let analyticsKey = "AnalyticsKey"
    static let crashReportKey = "CrashReportKey"
}
