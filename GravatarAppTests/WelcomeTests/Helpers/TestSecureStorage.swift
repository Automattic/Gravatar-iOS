import OAuth

final class TestSecureStorage: SecureStorage, @unchecked Sendable {
    var storage: [String: String] = [:]
    func setSecret(_ secret: any OAuth.SecureToken, for key: String) throws {
        storage[key] = secret.token
    }

    func deleteSecret(with key: String) throws {
        storage[key] = nil
    }

    func secret(with key: String) throws -> (any OAuth.SecureToken)? {
        guard let token = storage[key] else { return nil }
        return AccessToken(token: token)
    }
}
