import AuthenticationServices
import Gravatar

public struct OAuthManager: Sendable {
    public static let shared = OAuthManager()

    private var sessionData = SessionData()
    private let storage: SecureStorage
    private let authenticationSession: AuthenticationSession
    private let snakeCaseDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    init(authenticationSession: AuthenticationSession = WebAuthenticationSession(), storage: SecureStorage = Keychain()) {
        self.authenticationSession = authenticationSession
        self.storage = storage
    }

    public func hasSession(with email: Email) -> Bool {
        (try? storage.secret(with: email.rawValue) ?? nil) != nil
    }

    func overrideToken(_ token: KeychainToken, for email: Email) {
        deleteSession(with: email)
        try? storage.setSecret(token, for: email.rawValue)
    }

    public func deleteSession(with email: Email) {
        try? storage.deleteSecret(with: email.rawValue)
    }

    func sessionToken(with email: Email) -> KeychainToken? {
        try? storage.secret(with: email.rawValue)
    }

    public func requestSession(with email: Email) async throws(OAuthError) {
        guard let secrets = await Configuration.shared.secrets, let components = secrets.callbackURLComponents else {
            assertionFailure("Trying to retrieve access token without configuring oauth secrets.")
            throw OAuthError.notConfigured
        }

        await sessionData.save(email)
        do {
            let url = try oauthURL(with: email, secrets: secrets)
            let callbackURL = try await authenticationSession.authenticate(
                using: url,
                callbackURLComponents: components
            )
            _ = await handleCallback(callbackURL)
        } catch {
            throw OAuthError.from(error: error)
        }
    }

    func handleCallback(_ callbackURL: URL) async -> Bool {
        guard let email = await sessionData.restore() else { return false }

        do {
            let tokenText = try tokenResponse(from: callbackURL).token

            let newToken = KeychainToken(token: tokenText)
            overrideToken(newToken, for: email)
            await authenticationSession.cancel()
            Self.postNotification(.authorizationFinished)
            return true
        } catch OAuthError.couldNotParseAccessCode {
            await authenticationSession.cancel()
            Self.postNotification(.authorizationFinished)
            return false // The URL was not a Gravatar callback URL with a token.
        } catch {
            await authenticationSession.cancel()
            Self.postNotification(.authorizationError, error: error)
            return true
        }
    }

    private static func postNotification(_ name: Notification.Name, error: Error? = nil) {
        Task { @MainActor in
            NotificationCenter.default.post(name: name, object: error)
        }
    }

    private func tokenResponse(from callbackURL: URL) throws(OAuthError) -> AccessToken {
        guard let accessToken = AccessToken(from: callbackURL) else {
            throw OAuthError.couldNotParseAccessCode(callbackURL.absoluteString)
        }

        return accessToken
    }

    private func oauthURL(with email: Email, secrets: Configuration.Secrets) throws(OAuthError) -> URL {
        let params = OAuthURLParams(email: email, secrets: secrets)
        var urlComponents = URLComponents(string: "https://public-api.wordpress.com/oauth2/authorize")!
        do {
            urlComponents = try urlComponents.settingQueryItems(params.queryItems, shouldEncodePlusChar: true)
            guard let finalURL = urlComponents.url else {
                assertionFailure("Error encoding oauth secrets")
                throw OAuthError.couldNotCreateOAuthURLWithGivenSecrets
            }
            return finalURL
        } catch {
            assertionFailure("Error encoding oauth secrets")
            throw OAuthError.couldNotCreateOAuthURLWithGivenSecrets
        }
    }
}

// MARK: - Private helpers

private struct AccessTokenRequestParams: Encodable {
    let clientID: String
    let redirectURI: String
    let grantType: String = "authorization_code"
    let code: String

    init(secrets: Configuration.Secrets, code: String) {
        clientID = secrets.clientID
        redirectURI = secrets.redirectURI
        self.code = code
    }
}

private struct OAuthURLParams: Encodable {
    let clientID: String
    let responseType: String
    let blogID: String
    let redirectURI: String
    let userEmail: String
    var scope1: String
    var scope2: String
    var scope3: String

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case clientID
        case responseType
        case blogID
        case redirectURI
        case userEmail
        case scope1 = "scope[1]"
        case scope2 = "scope[2]"
        case scope3 = "scope[3]"
    }

    init(email: Email, secrets: Configuration.Secrets) {
        self.clientID = secrets.clientID
        self.responseType = "token"
        self.blogID = "0"
        self.redirectURI = secrets.redirectURI
        self.userEmail = email.rawValue
        self.scope1 = "gravatar-profile:read"
        self.scope2 = "gravatar-profile:manage"
        self.scope3 = "auth"
    }
}

private struct RemoteOAuthError: Decodable {
    let error: String
    let errorDescription: String
}

extension [URLQueryItem] {
    fileprivate var string: String? {
        var components = URLComponents()
        components.queryItems = self
        return components.query
    }
}

// Stores the email used for the current OAuth flow
private actor SessionData {
    private var current: Email?

    func save(_ email: Email) {
        current = email
    }

    func restore() -> Email? {
        let currentEmail = current
        return currentEmail
    }
}

extension Notification.Name {
    static let authorizationFinished = Notification.Name("com.GravatarSDK.AuthorizationFinished")
    static let authorizationError = Notification.Name("com.GravatarSDK.AuthorizationFinishedWithError")
}
