import Foundation

struct TokenCallbackParser: CallbackParser {
    func parse(from callbackURL: URL) async throws(OAuthError) -> AccessToken {
        guard
            let fragment = callbackURL.fragment(),
            let queryItems = URLComponents(string: "?" + fragment)?.queryItems
        else {
            throw .couldNotParseAccessCode(callbackURL.absoluteString)
        }

        let parameters = queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }

        guard let token = parameters["access_token"] else {
            throw .couldNotParseAccessCode(fragment)
        }

        return .init(token: token)
    }
}
