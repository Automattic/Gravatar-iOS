import Analytics

class UserUUIDStorageMock: UserUUIDStorage {
    var uuid: String?

    func set(_ uuid: String) {
        self.uuid = uuid
    }
}
