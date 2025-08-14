import Analytics
import Foundation

struct CommonAnalyticsEvent: AnalyticsEvent {
    let name: String
    let properties: EventProperties?

    init(name: String, properties: EventProperties? = nil) {
        self.name = name
        self.properties = properties
    }
}
