import AutomatticTracksEvents

public protocol Tracker {
    func track(_ name: String, withCustomProperties: [String: AnyHashable])
    func setUserProperty(_ value: AnyHashable, for key: String)
    func configure()
}

extension TracksService: Tracker {
    private enum Config {
        static let prefix = "gravatar_ios"
        static let userKey = "gravatar:user_id"
        static let platform = "gravatar"
    }

    public func track(_ name: String, withCustomProperties: [String : AnyHashable]) {
        trackEventName(name, withCustomProperties: withCustomProperties)
    }

    public func setUserProperty(_ value: AnyHashable, for key: String) {
        userProperties[key] = value
    }

    public func configure() {
        platform = Config.platform
        eventNamePrefix = Config.prefix
        authenticatedUserTypeKey = Config.userKey
    }
}
