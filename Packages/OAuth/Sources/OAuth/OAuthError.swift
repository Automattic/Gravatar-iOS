import AuthenticationServices

public enum OAuthError: Error {
    case notConfigured
    case configurationError
    case accessDenied
    case couldNotParseAccessCode(String)
    case oauthResponseError(String, ASWebAuthenticationSessionError.Code?)
    case tokenRequestError(URLError)
    case tokenResponseError(String)
    case decodingError(String)
    case unknown(Error)

    public var isAccessDenied: Bool {
        switch self {
        case .accessDenied: true
        default: false
        }
    }

    public var isCancelled: Bool {
        switch self {
        case .oauthResponseError(let error, let code) where code == .canceledLogin:
            // Taping on cancel and the "Using HTTPS callbacks requires Associated Domains" error are both code `canceledLogin`
            // We need to differenciate them to treate them differently.
            !error.contains("HTTPS")
        default: false
        }
    }

    public var errorDescription: String {
        switch self {
        case .couldNotParseAccessCode(let string):
            string
        case .oauthResponseError(let string, _):
            string
        case .tokenRequestError(let uRLError):
            uRLError.localizedDescription
        case .tokenResponseError(let string):
            string
        case .decodingError(let string):
            string
        case .unknown(let error):
            error.localizedDescription
        case .notConfigured, .configurationError:
            "\(self)"
        default:
            "Unknown error"
        }
    }
}

extension OAuthError {
    static func from(error: Error) -> OAuthError {
        switch error {
        case let error as OAuthError:
            return error
        case let error as DecodingError:
            assertionFailure("Unable to decode the response. Error: \(error.localizedDescription)")
            return .decodingError(error.localizedDescription)
        case let error as URLError:
            return .tokenRequestError(error)
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
