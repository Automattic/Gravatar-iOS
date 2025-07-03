import Foundation
@testable import GravatarApp
import GravatarUI

final class URLSessionAvatarPickerMock: URLSessionProtocol {
    static let internetLostErrorMessage: String = "The network connection was lost"
    let returnErrorCode: Int?

    var shouldSimulateNoNetworkConnection: Bool

    init(returnErrorCode: Int? = nil, shouldSimulateNoNetworkConnection: Bool = false) {
        self.returnErrorCode = returnErrorCode
        self.shouldSimulateNoNetworkConnection = shouldSimulateNoNetworkConnection
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if shouldSimulateNoNetworkConnection {
            throw NSError(
                domain: NSURLErrorDomain,
                code: -1005,
                userInfo: [NSLocalizedDescriptionKey: URLSessionAvatarPickerMock.internetLostErrorMessage]
            )
        }

        if let returnErrorCode {
            return (Data("".utf8), HTTPURLResponse.errorResponse(code: returnErrorCode))
        }

        if request.isSetAvatarForEmailRequest {
            return (Bundle.postAvatarSelectedJsonData, HTTPURLResponse.successResponse()) // Avatars data
        }

        if request.isDeleteAvatarRequest {
            return (Data("".utf8), HTTPURLResponse.successResponse())
        }

        if request.isSetAvatarAltTextRequest {
            return (Bundle.setAltTextJsonData, HTTPURLResponse.successResponse()) // Avatar data
        }

        if request.isProfilesRequest {
            return (Bundle.fullProfileJsonData, HTTPURLResponse.successResponse()) // Profile data
        } else if request.isAvatarsRequest == true {
            return (Bundle.getAvatarsJsonData, HTTPURLResponse.successResponse()) // Avatars data
        }

        fatalError("Request not mocked: \(request.url?.absoluteString ?? "unknown request")")
    }

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        if shouldSimulateNoNetworkConnection {
            throw NSError(
                domain: NSURLErrorDomain,
                code: -1005,
                userInfo: [NSLocalizedDescriptionKey: URLSessionAvatarPickerMock.internetLostErrorMessage]
            )
        }
        if let returnErrorCode {
            return (Data("".utf8), HTTPURLResponse.errorResponse(code: returnErrorCode))
        }
        return (Bundle.postAvatarUploadJsonData, HTTPURLResponse.successResponse())
    }
}

extension URLRequest {
    private enum RequestType: String {
        case profiles = "/me/profile"
        case avatars
    }

    fileprivate var isAvatarsRequest: Bool {
        self.url?.absoluteString.contains(RequestType.avatars.rawValue) == true
    }

    fileprivate var isProfilesRequest: Bool {
        self.url?.absoluteString.contains(RequestType.profiles.rawValue) == true
    }

    fileprivate var isDeleteAvatarRequest: Bool {
        guard self.httpMethod == "DELETE",
              self.isAvatarsRequest
        else {
            return false
        }
        return true
    }

    fileprivate var isSetAvatarAltTextRequest: Bool {
        guard
            self.httpMethod == "PATCH",
            self.isAvatarsRequest
        else {
            return false
        }
        return self.httpBody.contains("alt_text")
    }

    fileprivate var isSetAvatarForEmailRequest: Bool {
        guard self.httpMethod == "POST",
              self.isAvatarsRequest
        else {
            return false
        }
        return self.httpBody.contains("email_hash")
    }
}

extension Data? {
    fileprivate func contains(_ content: String) -> Bool {
        guard let self else { return false }
        return String(data: self, encoding: .utf8)?.contains(content) == true
    }
}
