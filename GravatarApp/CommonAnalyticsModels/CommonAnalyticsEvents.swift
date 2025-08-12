import Analytics
import Foundation

struct CommonAnalyticsEvent: AnalyticsEvent {
    let name: String
    let properties: EventProperties?
}

struct NoPropertyAnalyticsEvent: AnalyticsEvent {
    let name: String
    let properties: EventProperties? = nil
}
