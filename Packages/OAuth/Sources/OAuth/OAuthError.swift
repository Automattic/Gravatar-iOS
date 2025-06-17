import AuthenticationServices

public enum OAuthError: Error {
    case notConfigured
    case couldNotCreateOAuthURLWithGivenSecrets
    case couldNotParseAccessCode(String)
    case oauthResponseError(String, ASWebAuthenticationSessionError.Code?)
    case unknown(Error)
    case couldNotStoreToken(Error)
    case decodingError(Error)
}

extension OAuthError {
    static func from(error: Error) -> OAuthError {
        switch error {
        case let error as OAuthError:
            return error
        case let error as Keychain.KeychainError:
            return .couldNotStoreToken(error)
        case let error as DecodingError:
            assertionFailure("Unable to decode the response. Error: \(error.localizedDescription)")
            return OAuthError.decodingError(error)
        case let error as NSError:
            if error.domain == ASWebAuthenticationSessionErrorDomain {
                return .oauthResponseError(error.localizedDescription, ASWebAuthenticationSessionError.Code(rawValue: error.code))
            }
            return .unknown(error)
        default:
            return .unknown(error)
        }
    }
}
