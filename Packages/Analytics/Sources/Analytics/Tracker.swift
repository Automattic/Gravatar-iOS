import AutomatticTracksEvents

public protocol Tracker {
    func track(_ name: String, withCustomProperties: [String: AnyHashable])
    func setUserProperty(_ value: AnyHashable, for key: String)
    func setUserID(_ userID: String?, userUUIDStorage: UserUUIDStorage)
    func configure()
}

extension TracksService: Tracker {
    public func setUserID(_ userID: String?, userUUIDStorage: UserUUIDStorage) {
        if let userID {
            switchToAuthenticatedUser(withUsername: nil, userID: userID, skipAliasEventCreation: true)
        } else {
            switchToAnonymousUser(withAnonymousID: UserUUID(storage: userUUIDStorage).uuidString)
        }
    }

    private enum Config {
        static let prefix = "gravatar_ios"
        static let userKey = "wpcom:user_id"
        static let platform = "gravatar"
    }

    public func track(_ name: String, withCustomProperties: [String: AnyHashable]) {
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
