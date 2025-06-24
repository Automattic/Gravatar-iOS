@preconcurrency import AuthenticationServices
import SwiftUI

final class WebAuthenticationSession: NSObject, Sendable {
    private let sessionStorage = SessionStorage()

    func authenticate(using url: URL, callbackURLComponents: URLComponents) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callback: authSessionCallback(with: callbackURLComponents),
                completionHandler: authSessionCompletionHandler(with: continuation)
            )

            Task { @MainActor in
                await sessionStorage.save(session)
                session.presentationContextProvider = self
                session.start()
            }
        }
    }

    func cancel() {
        Task { @MainActor in
            guard let session = await sessionStorage.restore() else { return }
            session.cancel()
        }
    }

    @available(iOS 17.4, *)
    private func authSessionCallback(with components: URLComponents) -> ASWebAuthenticationSession.Callback {
        if components.scheme == "https", let host = components.host {
            .https(host: host, path: components.path)
        } else {
            .customScheme(components.scheme ?? "")
        }
    }

    private func authSessionCompletionHandler(with continuation: CheckedContinuation<URL, any Error>) -> ASWebAuthenticationSession.CompletionHandler {
        { callbackURL, error in
            if let error {
                continuation.resume(throwing: error)
            } else if let callbackURL {
                continuation.resume(returning: callbackURL)
            }
        }
    }
}

extension WebAuthenticationSession: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}

// `ASWebAuthenticationSession` is not thread safe. `SessionStorage` helps to silence some warnings (Swift 6 errors),
// but we are still importing `AuthenticationServices` as `@preconcurrency`.
// On the other hand, there won't be more than one attempt of oauth at a time, which reduces possible concurrency issues.
private actor SessionStorage {
    var current: ASWebAuthenticationSession?

    func save(_ session: ASWebAuthenticationSession) {
        current = session
    }

    func restore() -> ASWebAuthenticationSession? {
        let currentSession = current
        return currentSession
    }
}
