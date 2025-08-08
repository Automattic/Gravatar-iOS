import Foundation

struct AccountService {
    let userSession: UserSession

    func deleteAccount() async throws {
        guard
            let deleteURL = URL(string: "https://api.gravatar.com/v3/me/status")
        else { return }

        let token = await userSession.accessToken

        var request = URLRequest(url: deleteURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = "{\"status\":\"disabled\"}".data(using: .utf8)

        _ = try await GravatarURLSession.shared.data(for: request)
    }
}
