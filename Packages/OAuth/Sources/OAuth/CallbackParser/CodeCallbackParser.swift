import Foundation

protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

struct CodeCallbackParser: CallbackParser {
    let urlSession: URLSessionProtocol

    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }

    func parse(from callbackURL: URL) async throws(OAuthError) -> AccessToken {
        let response = parseCode(from: callbackURL)

        if let code = response.code {
            return try await requestAccessToken(with: code)
        } else if let error = response.error, error == "access_denied" {
            throw OAuthError.accessDenied
        }
        throw OAuthError.couldNotParseAccessCode(callbackURL.absoluteString)
    }

    func parseCode(from callbackURL: URL) -> (code: String?, error: String?) {
        guard
            let components = URLComponents(string: callbackURL.absoluteString),
            let queryItems = components.queryItems
        else { return (nil, nil) }

        let parameters = queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }

        return (parameters["code"], parameters["error"])
    }

    private func requestAccessToken(with code: String) async throws(OAuthError) -> AccessToken {
        guard let secrets = await Configuration.shared.secrets else {
            assertionFailure("Trying to retrieve access token without configuring oauth secrets.")
            throw OAuthError.notConfigured
        }

        return try await performTokenRequest(with: secrets, code: code)
    }

    private func performTokenRequest(with secrets: Configuration.Secrets, code: String) async throws(OAuthError) -> AccessToken {
        let tokenRequest = URLRequest.oauth2TokenRequest(with: secrets, code: code)

        do {
            let (data, _) = try await urlSession.data(for: tokenRequest, delegate: nil)

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            guard let token = try? decoder.decode(Response.self, from: data).accessToken else {
                // Check for error in response
                let error = try decoder.decode(RemoteOAuthError.self, from: data)
                throw OAuthError.tokenResponseError("\(error.error): \(error.errorDescription)")
            }

            return AccessToken(token: token)
        } catch {
            throw OAuthError.from(error: error)
        }
    }
}

extension URLRequest {
    fileprivate static func oauth2TokenRequest(with secrets: Configuration.Secrets, code: String) -> URLRequest {
        var tokenRequest = URLRequest(url: URL(string: "https://public-api.wordpress.com/oauth2/token")!)
        tokenRequest.httpMethod = "POST"
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "client_id", value: secrets.clientID),
            URLQueryItem(name: "client_secret", value: secrets.clientSecret),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: secrets.redirectURI),
        ]
        tokenRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        tokenRequest.httpBody = components.query?.data(using: .utf8)
        return tokenRequest
    }
}

private struct Response: Decodable {
    var accessToken: String
}

private struct RemoteOAuthError: Decodable {
    let error: String
    let errorDescription: String
}
