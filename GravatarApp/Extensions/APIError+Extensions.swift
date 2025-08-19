import Foundation
import Gravatar

extension APIError {
    var isNotConnectedToInternet: Bool {
        switch self {
        case .responseError(reason: .URLSessionError(error: let error)):
            (error as NSError).domain == NSURLErrorDomain && (error as NSError).code == NSURLErrorNotConnectedToInternet
        default:
            false
        }
    }
}
