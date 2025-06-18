import Gravatar
@testable import OAuth

import SwiftUI
import Testing

private let redirectURI = "https://gravatar.com/callback"
private let clientID = "clientID"

struct OauthManagerTests {
    let callbackURI = URL(string: "https://gravatar.com/#access_token=YOUR_API_TOKEN&expires_in=64800&token_type=bearer&site_id=01")!
    let email = Email("some@email.com")

    init() async throws {
        await Configuration.shared.setSecrets(.init(
            clientID: clientID,
            redirectURI: redirectURI
        ))
    }

    @Test("Calling requestSession successfully will save a session")
    func oauthHasSession() async throws {
        let manager = getManager()
        try await manager.requestSession(with: .init("some@email.com"))

        #expect(manager.hasSession(with: email))
    }

    @Test("Calling requestSession successfully will parce and store the token")
    func oauthParceToken() async throws {
        let manager = getManager()
        try await manager.requestSession(with: .init("some@email.com"))
        let token = manager.sessionToken(with: email)

        #expect(token?.token == "YOUR_API_TOKEN")
    }

    @Test("Calling requestSession with error should throw")
    func requestSessionThrows() async throws {
        let error = OAuthError.unknown(NSError(domain: "OAuth", code: 1))
        let manager = getManager(error: error)

        await #expect(throws: OAuthError.self) {
            try await manager.requestSession(with: email)
        }
    }

    @Test("Unknown callback URI should cancel session")
    func unkonwnCallbackThrows() async throws {
        let session = AuthenticationSessionMock(
            callbackURI: URL(string: "gravatar.com/not_a_token")!
        )
        let manager = getManager(session: session)
        try await manager.requestSession(with: email)
        #expect(await session.cancelled)
    }

    @Test("Parameters are added to request URL", arguments: [
        URLQueryItem(name: "response_type", value: "code"),
        URLQueryItem(name: "scope[1]", value: "global"),
        URLQueryItem(name: "client_id", value: clientID),
        URLQueryItem(name: "redirect_uri", value: redirectURI),
    ])
    func requestURLWithParams(queryItem: URLQueryItem) async throws {
        let session = AuthenticationSessionMock(callbackURI: callbackURI)
        let manager = getManager(session: session)
        try await manager.requestSession(with: email)

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
        error: Error? = nil
    ) -> OAuthManager {
        OAuthManager(
            authenticationSession: session ?? AuthenticationSessionMock(
                callbackURI: callbackURI ?? self.callbackURI,
                error: error
            ),
            storage: SecureStorageMock()
        )
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
