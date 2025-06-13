import Analytics

final class TrackerMock: Tracker {
    var eventTracked: String? = nil
    var propertiesTracked: [String: AnyHashable]? = nil
    var configureCalled = false
    var userProperties: [String: AnyHashable] = [:]

    func track(_ name: String, withCustomProperties: [String : AnyHashable]) {
        eventTracked = name
        propertiesTracked = withCustomProperties
    }

    func setUserProperty(_ value: AnyHashable, for key: String) {
        userProperties[key] = value
    }

    func configure() {
        configureCalled = true
    }
}
