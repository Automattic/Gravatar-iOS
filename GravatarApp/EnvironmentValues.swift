import SwiftUI

// MARK: - Analytics

import Analytics
extension EnvironmentValues {
    var analytics: Analytics {
        get {
            self[AnalyticsKey.self]
        }
        set {
            self[AnalyticsKey.self] = newValue
        }
    }
}

struct AnalyticsKey: EnvironmentKey {
    @MainActor
    static var defaultValue: Analytics { .init() }
}
