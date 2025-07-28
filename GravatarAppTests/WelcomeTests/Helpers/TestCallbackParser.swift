import Foundation
import OAuth

final class TestCallbackParser: CallbackParser, @unchecked Sendable {
    var url: URL? = nil
    let token: String

    init(token: String) {
        self.token = token
    }

    func parse(from callbackURL: URL) async throws(OAuth.OAuthError) -> OAuth.AccessToken {
        url = callbackURL
        return AccessToken(token: token)
    }
}
