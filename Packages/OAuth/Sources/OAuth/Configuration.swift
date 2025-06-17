import Foundation
import SwiftUI

actor Configuration {
    struct Secrets: Sendable {
        let clientID: String
        let redirectURI: String
        var callbackScheme: String {
            callbackURLComponents?.scheme ?? ""
        }

        var callbackURLComponents: URLComponents? {
            URLComponents(string: redirectURI)
        }

        init(clientID: String, redirectURI: String) {
            self.clientID = clientID
            self.redirectURI = redirectURI
        }
    }

    static let shared = Configuration()
    var secrets: Secrets? = nil

    func setSecrets(_ secrets: Secrets) {
        self.secrets = secrets
    }
}

extension View {
    public func configureOAuth(clientID: String, redirectURI: String) -> some View {
        self.modifier(OAuthConfigurationModifier(clientID: clientID, redirectURI: redirectURI))
    }
}

struct OAuthConfigurationModifier: ViewModifier {
    let clientID: String
    let redirectURI: String

    func body(content: Self.Content) -> some View {
        content.onAppear {
            Task {
                await OAuth.Configuration.shared.setSecrets(
                    .init(clientID: clientID, redirectURI: redirectURI)
                )
            }
        }
    }
}
