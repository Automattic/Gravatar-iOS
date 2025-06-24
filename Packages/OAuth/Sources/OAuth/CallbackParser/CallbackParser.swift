import Foundation

protocol CallbackParser: Sendable {
    func parse(from callbackURL: URL) async throws(OAuthError) -> AccessToken
}
