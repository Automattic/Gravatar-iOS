import Foundation

struct TokenCallbackParser: CallbackParser {
    func parse(from callbackURL: URL) async -> AccessToken? {
        guard
            let fragment = callbackURL.fragment(),
            let queryItems = URLComponents(string: "?" + fragment)?.queryItems
        else { return nil }

        let parameters = queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }

        guard let token = parameters["access_token"] else { return nil }

        return .init(token: token)
    }
}
