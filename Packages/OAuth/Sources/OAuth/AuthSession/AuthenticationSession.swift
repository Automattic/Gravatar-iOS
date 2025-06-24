import Foundation

protocol AuthenticationSession: Sendable {
    func authenticate(using url: URL, callbackURLComponents: URLComponents) async throws -> URL
    func cancel() async
}

extension WebAuthenticationSession: AuthenticationSession {}
