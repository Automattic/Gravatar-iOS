@testable import Analytics

class UserUUIDStorageMock: UserUUIDStorage {
    var uuid: String?

    func set(_ uuid: String) {
        self.uuid = uuid
    }
}

final class TrackerMock: Tracker, @unchecked Sendable {
    var configureCalled = false
    var userProperties: [String: AnyHashable] = [:]
    var userName: String?
    var trackedEvents: [(name: String, properties: [String: AnyHashable])] = []

    func track(_ name: String, withCustomProperties properties: [String: AnyHashable]) {
        trackedEvents.append((name: name, properties: properties))
    }

    func setUserProperty(_ value: AnyHashable, for key: String) {
        userProperties[key] = value
    }

    func setUserName(_ userName: String?, userUUIDStorage: any UserUUIDStorage) {
        self.userName = userName
    }

    func configure() {
        configureCalled = true
    }

    func tracked(event: AnalyticsEvent, count: Int = 1) -> Bool {
        trackedEvents.filter { $0.name == event.name }.count == count
    }

    func tracked(event: AnalyticsEvent, with properties: [String: AnyHashable], count: Int = 1) -> Bool {
        trackedEvents.filter { event.name == $0.name && $0.properties == properties }.count == count
    }
}

extension Analytics {
    static let test = Analytics(tracker: TrackerMock(), userUUIDStorage: UserUUIDStorageMock())
}
