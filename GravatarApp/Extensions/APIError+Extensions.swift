import Foundation
import Gravatar

extension APIError {
    var isNotConnectedToInternet: Bool {
        switch self {
        case .responseError(reason: .URLSessionError(error: let error)):
            let error = error as NSError
            return error.domain == NSURLErrorDomain &&
            (
                error.code == NSURLErrorNotConnectedToInternet ||
                error.code == NSURLErrorNetworkConnectionLost
            )
        default:
            return false
        }
    }
}
