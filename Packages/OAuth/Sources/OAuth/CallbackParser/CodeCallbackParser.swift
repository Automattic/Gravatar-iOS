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

    func parse(from callbackURL: URL) async -> AccessToken? {
        guard let code = parseCode(from: callbackURL) else {
            return nil
        }

        return try? await requestAccessToken(with: code)
    }

    func parseCode(from callbackURL: URL) -> String? {
        guard
            let components = URLComponents(string: callbackURL.absoluteString),
            let queryItems = components.queryItems
        else { return nil }

        let parameters = queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }

        return parameters["code"]
    }

    private func requestAccessToken(with code: String) async throws(OAuthError) -> AccessToken {
        guard let secrets = await Configuration.shared.secrets else {
            assertionFailure("Trying to retrieve access token without configuring oauth secrets.")
            throw OAuthError.notConfigured
        }

        let parameters = AccessTokenRequestParams(
            secrets: secrets,
            code: code
        )

        return try await performTokenRequest(with: parameters)
    }

    private func performTokenRequest(with parameters: AccessTokenRequestParams) async throws(OAuthError) -> AccessToken {
        let tokenRequest = URLRequest.oauth2TokenRequest(with: parameters)

        do {
            let (data, _) = try await urlSession.data(for: tokenRequest, delegate: nil)

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            guard let token = try? decoder.decode(Response.self, from: data).accessToken else {
                // Check for error response
                let error = try decoder.decode(RemoteOAuthError.self, from: data)
                throw OAuthError.decodingError("\(error.error): \(error.errorDescription)")
            }

            return AccessToken(token: token)
        } catch let oauthError as OAuthError {
            throw oauthError
        } catch let error as URLError {
            throw .tokenRequestError(error)
        } catch let error as DecodingError {
            throw .decodingError(error.localizedDescription)
        } catch {
            throw .unknown(error)
        }
    }
}

extension URLRequest {
    fileprivate static func oauth2TokenRequest(with parameters: AccessTokenRequestParams) -> URLRequest {
        var request = URLRequest(url: URL(string: "https://public-api.wordpress.com/oauth2/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder.snakeCaseEncoder.encode(parameters)
        return request
    }
}

private struct Response: Decodable {
    var accessToken: String
}

private struct AccessTokenRequestParams: Encodable {
    let grantType = "authorization_code"
    let clientID: String
    let clientSecret: String
    let redirectURI: String
    let code: String

    init(secrets: Configuration.Secrets, code: String) {
        self.clientID = secrets.clientID
        self.clientSecret = secrets.clientSecret
        self.redirectURI = secrets.redirectURI
        self.code = code
    }
}

private struct RemoteOAuthError: Decodable {
    let error: String
    let errorDescription: String
}
