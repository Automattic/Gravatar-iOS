import AutomatticTracksEvents

public protocol Tracker: Sendable {
    func track(_ name: String, withCustomProperties: [String: AnyHashable])
    func setUserProperty(_ value: AnyHashable, for key: String)
    func setUserName(_ userName: String?, userUUIDStorage: UserUUIDStorage)
    func configure()
}

extension TracksService: Tracker, @unchecked @retroactive Sendable {
    public func setUserName(_ userName: String?, userUUIDStorage: UserUUIDStorage) {
        if let userName {
            // Tracks backend will figure out WPCom userID from the userName.
            switchToAuthenticatedUser(withUsername: userName, userID: nil, skipAliasEventCreation: true)
        } else {
            switchToAnonymousUser(withAnonymousID: UserUUID(storage: userUUIDStorage).uuidString)
        }
    }

    private enum Config {
        static let prefix = "gravatarios"
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
