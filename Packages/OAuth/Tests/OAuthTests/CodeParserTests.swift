import Foundation
@testable import OAuth
import Testing

@Test("Test CodeParser can parse the code and request the token")
func codeParser() async throws {
    await Configuration.shared.setSecrets(.init(clientID: "", clientSecret: "", redirectURI: ""))
    let response = ["access_token": "ACCESS_TOKEN"]
    let parser = CodeCallbackParser(urlSession: URLSessionMock(returnBody: response))
    let token = try await parser.parse(from: URL(string: "https://example.com/callback?code=12345")!)

    #expect(token.token == "ACCESS_TOKEN")
}

struct URLSessionMock: URLSessionProtocol, @unchecked Sendable {
    let returnBody: [String: Any]

    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        (
            try! JSONSerialization.data(withJSONObject: returnBody),
            URLResponse()
        )
    }
}
