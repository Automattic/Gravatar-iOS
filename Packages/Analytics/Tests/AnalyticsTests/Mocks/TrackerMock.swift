import Analytics
import Foundation

final class TrackerMock: Tracker {
    var eventTracked: String? = nil
    var propertiesTracked: [String: AnyHashable]? = nil
    var configureCalled = false
    var userProperties: [String: AnyHashable] = [:]
    var userName: String? = nil

    func track(_ name: String, withCustomProperties: [String: AnyHashable]) {
        eventTracked = name
        propertiesTracked = withCustomProperties
    }

    func setUserProperty(_ value: AnyHashable, for key: String) {
        userProperties[key] = value
    }

    func configure() {
        configureCalled = true
    }

    func setUserName(_ userName: String?, userUUIDStorage: UserUUIDStorage) {
        self.userName = userName
        if userName == nil {
            userUUIDStorage.set(UUID().uuidString)
        }
    }
}
