@testable import OAuth

import SwiftUI
import Testing

private let redirectURI = "https://gravatar.com/callback"
private let clientID = "clientID"
private let clientSecret = "secret"

struct OauthManagerTests {
    let callbackURLToken = URL(string: "https://gravatar.com/#access_token=YOUR_API_TOKEN&expires_in=64800&token_type=bearer&site_id=01")!
    let callbackURLCode = URL(string: "https://developer.wordpress.com/?code=cw9hk1xG9k")!

    init() async throws {
        await Configuration.shared.setSecrets(.init(
            clientID: clientID,
            clientSecret: clientSecret,
            redirectURI: redirectURI
        ))
    }

    @Test("Calling requestSession with type CODE successfully returns a token")
    func codeOAuthReturnsToken() async throws {
        let manager = getManager()
        let token = try await manager.requestAccessToken()

        #expect(token.token == "YOUR_API_TOKEN")
    }

    @Test("Calling requestSession with type TOKEN successfully returns a token")
    func tokenOAuthReturnsToken() async throws {
        let manager = getManager(callbackURI: callbackURLToken, parser: TokenCallbackParser())
        let token = try await manager.requestAccessToken()

        #expect(token.token == "YOUR_API_TOKEN")
    }

    @Test("Calling requestSession with error should throw")
    func requestSessionThrows() async throws {
        let error = OAuthError.unknown(NSError(domain: "OAuth", code: 1))
        let manager = getManager(error: error)

        await #expect(throws: OAuthError.self) {
            try await manager.requestAccessToken()
        }
    }

    @Test("Unknown callback URI should cancel session")
    func unkonwnCallbackThrows() async throws {
        let session = AuthenticationSessionMock(
            callbackURI: URL(string: "gravatar.com/not_a_token")!
        )
        let manager = getManager(session: session)
        await #expect(throws: OAuthError.self) {
            _ = try await manager.requestAccessToken()
        }
    }

    @Test("Parameters are added to request URL", arguments: [
        URLQueryItem(name: "response_type", value: "code"),
        URLQueryItem(name: "scope[0]", value: "auth"),
        URLQueryItem(name: "scope[1]", value: "gravatar-global"),
        URLQueryItem(name: "client_id", value: clientID),
        URLQueryItem(name: "redirect_uri", value: redirectURI),
    ])
    func requestURLWithParams(queryItem: URLQueryItem) async throws {
        let session = AuthenticationSessionMock(callbackURI: callbackURLCode)
        let manager = getManager(session: session)
        _ = try await manager.requestAccessToken()

        let components = await URLComponents(string: session.requestURL?.absoluteString ?? "")

        #expect(
            components?.queryItems?.contains(queryItem) == true
        )
    }
}

extension OauthManagerTests {
    private func getManager(
        session: AuthenticationSessionMock? = nil,
        callbackURI: URL? = nil,
        parser: CallbackParser? = nil,
        error: Error? = nil
    ) -> OAuthManager {
        OAuthManager(
            authenticationSession: session ?? AuthenticationSessionMock(
                callbackURI: callbackURI ?? self.callbackURLCode,
                error: error
            ),
            storage: SecureStorageMock(),
            callbackParser: parser ?? CodeCallbackParser(urlSession: CodeCallbackURLSession())
        )
    }
}

final class CodeCallbackURLSession: URLSessionProtocol {
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        let responseData = """
        {
        "access_token": "YOUR_API_TOKEN",
        "blog_id": "blog ID",
        "blog_url": "blog url",
        "token_type": "bearer"
        }
        """.data(using: .utf8)!

        return (responseData, HTTPURLResponse())
    }
}

final actor AuthenticationSessionMock: AuthenticationSession {
    var requestURL: URL?
    let callbackURI: URL
    let error: Error?
    var cancelled = false

    init(callbackURI: URL, error: Error? = nil) {
        self.callbackURI = callbackURI
        self.error = error
    }

    func authenticate(using url: URL, callbackURLComponents: URLComponents) async throws -> URL {
        requestURL = url
        if let error {
            throw error
        }
        return callbackURI
    }

    func cancel() async {
        cancelled = true
    }
}

final class SecureStorageMock: SecureStorage, @unchecked Sendable {
    var storage: [String: OAuth.SecureToken] = .init()

    func setSecret(_ secret: OAuth.SecureToken, for key: String) throws {
        storage[key] = secret
    }

    func deleteSecret(with key: String) throws {
        storage.removeValue(forKey: key)
    }

    func secret(with key: String) throws -> OAuth.SecureToken? {
        storage[key]
    }
}
