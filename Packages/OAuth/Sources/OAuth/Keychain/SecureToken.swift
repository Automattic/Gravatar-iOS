import Foundation

public protocol SecureToken {
    var token: String { get }
    var data: Data? { get }
}

extension SecureToken {
    public var data: Data? {
        token.data(using: .utf8)
    }
}

extension AccessToken: SecureToken {
    init?(data: Data) {
        guard let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        self.token = token
    }
}
