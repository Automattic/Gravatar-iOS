import Foundation

public protocol UserUUIDStorage {
    var uuid: String? { get }
    func set(_ uuid: String)
}

extension UserDefaults: UserUUIDStorage {
    private static let userUUIDKey = "kAnalyticsAnonUserUUID"

    public var uuid: String? {
        string(forKey: Self.userUUIDKey)
    }

    public func set(_ uuid: String) {
        set(uuid, forKey: Self.userUUIDKey)
    }
}

/// Generates and persists a UUID for the user.
struct UserUUID {
    let storage: UserUUIDStorage

    init(storage: UserUUIDStorage) {
        self.storage = storage
    }

    /// The user unique ID.
    var uuidString: String {
        if let uuid = storage.uuid {
            return uuid
        }

        let uuid = UUID().uuidString
        storage.set(uuid)

        return uuid
    }
}
