import Foundation

extension URLComponents {
    func settingQueryItems(_ queryItems: [URLQueryItem], shouldEncodePlusChar: Bool = false) -> URLComponents {
        var copy = self

        guard !queryItems.isEmpty else {
            copy.queryItems = nil
            return copy
        }

        copy.queryItems = queryItems

        if shouldEncodePlusChar {
            copy.percentEncodedQuery = copy.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        }

        return copy
    }
}
