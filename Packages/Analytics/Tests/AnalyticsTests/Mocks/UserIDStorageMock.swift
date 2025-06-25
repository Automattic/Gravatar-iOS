import Analytics

class UserUUIDStorageMock: UserUUIDStorage, @unchecked Sendable {
    var uuid: String?

    func set(_ uuid: String) {
        self.uuid = uuid
    }
}
