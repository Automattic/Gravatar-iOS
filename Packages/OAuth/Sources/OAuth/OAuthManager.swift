import AuthenticationServices

public struct OAuthManager: Sendable {
    public static let shared = OAuthManager()

    private let storage: SecureStorage
    private let authenticationSession: AuthenticationSession

    private let callbackParser: CallbackParser = TokenCallbackParser()

    init(authenticationSession: AuthenticationSession = WebAuthenticationSession(), storage: SecureStorage = Keychain()) {
        self.authenticationSession = authenticationSession
        self.storage = storage
    }

    // MARK: Keychain helpers

    public func hasSession(with key: String) -> Bool {
        (try? storage.secret(with: key) ?? nil) != nil
    }

    public func saveToken(_ token: SecureToken, withKey key: String) {
        try? storage.setSecret(token, for: key)
    }

    public func deleteToken(with key: String) {
        try? storage.deleteSecret(with: key)
    }

    public func sessionToken(with key: String) -> SecureToken? {
        try? storage.secret(with: key)
    }

    // MARK: Token request

    public func requestAccessToken() async throws(OAuthError) -> AccessToken {
        guard let secrets = await Configuration.shared.secrets, let components = secrets.callbackURLComponents else {
            assertionFailure("Trying to retrieve access token without configuring oauth secrets.")
            throw OAuthError.notConfigured
        }

        do {
            let url = try oauthURL(with: secrets)
            let callbackURL = try await authenticationSession.authenticate(
                using: url,
                callbackURLComponents: components
            )
            return try await handleCallback(callbackURL)
        } catch {
            throw OAuthError.from(error: error)
        }
    }

    func handleCallback(_ callbackURL: URL) async throws(OAuthError) -> AccessToken {
        let token = try await callbackParser.parse(from: callbackURL)
        await authenticationSession.cancel()
        return token
    }

    private func oauthURL(with secrets: Configuration.Secrets) throws(OAuthError) -> URL {
        let params = OAuthURLParams(secrets: secrets)
        var urlComponents = URLComponents(string: "https://public-api.wordpress.com/oauth2/authorize")!
        do {
            urlComponents = try urlComponents.settingQueryItems(params.queryItems, shouldEncodePlusChar: true)
            guard let finalURL = urlComponents.url else {
                assertionFailure("Error encoding oauth secrets")
                throw OAuthError.configurationError
            }
            return finalURL
        } catch {
            assertionFailure("Error encoding oauth secrets")
            throw OAuthError.configurationError
        }
    }
}

// MARK: - Private helpers

private struct OAuthURLParams: Encodable {
    let clientID: String
    let responseType: String
    let redirectURI: String
    let scope0: String
    let scope1: String

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case clientID
        case responseType
        case redirectURI
        case scope0 = "scope[0]"
        case scope1 = "scope[1]"
    }

    init(secrets: Configuration.Secrets) {
        self.clientID = secrets.clientID
        self.responseType = "code"
        self.redirectURI = secrets.redirectURI
        self.scope0 = "auth"
        self.scope1 = "gravatar-global"
    }
}

extension JSONEncoder {
    static var snakeCaseEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}

extension OAuthURLParams {
    var queryItems: [URLQueryItem] {
        get throws {
            let encoder = JSONEncoder.snakeCaseEncoder
            let data = try encoder.encode(self)
            let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: String]
            return dictionary?.map {
                URLQueryItem(name: $0.key, value: $0.value)
            } ?? []
        }
    }
}

extension [URLQueryItem] {
    fileprivate var string: String? {
        var components = URLComponents()
        components.queryItems = self
        return components.query
    }
}
