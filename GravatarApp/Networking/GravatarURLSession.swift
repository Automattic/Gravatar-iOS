import Foundation
import Gravatar

/// Intercepts the network requests to perform common operations.
final class GravatarURLSession: URLSessionProtocol, Sendable {
    static let shared = GravatarURLSession()
    let urlSession: URLSession

    private init() {
        self.urlSession = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: nil
        )
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let result = try await urlSession.data(for: request)
        if let httpResponse = result.1 as? HTTPURLResponse,
           httpResponse.statusCode == HTTPStatus.unauthorized.rawValue
        {
            Task { @MainActor in
                NotificationCenter.default.post(name: .sessionExpired, object: nil)
            }
        }
        return result
    }

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        let result = try await urlSession.upload(for: request, from: bodyData)
        if let httpResponse = result.1 as? HTTPURLResponse,
           httpResponse.statusCode == HTTPStatus.unauthorized.rawValue
        {
            Task { @MainActor in
                NotificationCenter.default.post(name: .sessionExpired, object: nil)
            }
        }
        return result
    }
}
