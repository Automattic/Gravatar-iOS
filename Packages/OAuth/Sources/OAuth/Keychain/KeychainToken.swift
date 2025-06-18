import Foundation

struct KeychainToken: Codable {
    let token: String

    init?(data: Data) {
        guard let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        self.token = token
    }

    init(token: String) {
        self.token = token
    }

    var data: Data? {
        token.data(using: .utf8)
    }
}
