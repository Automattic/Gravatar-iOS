import Foundation
import OAuth

final class TestOAuthSession: AuthenticationSession, @unchecked Sendable {
    var cancelled: Bool = false
    let callbackURL: URL
    var error: OAuthError?

    init(callbackURL: URL) {
        self.callbackURL = callbackURL
    }

    func authenticate(using url: URL, callbackURLComponents: URLComponents) async throws -> URL {
        if let error {
            throw error
        }
        return callbackURL
    }

    func cancel() async {
        cancelled = true
    }
}
