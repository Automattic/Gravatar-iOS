import Analytics
import Gravatar
import SwiftUI

struct ContentView: View {
    @State private var profile: Profile

    let onLogout: () -> Void

    init(profile: Profile, onLogout: @escaping () -> Void) {
        self._profile = State(initialValue: profile)
        self.onLogout = onLogout
    }

    var body: some View {
        VStack {
            profileView(with: profile)
            Button("Logout") {
                onLogout()
            }
        }
        .padding()
    }

    func fetchProfile() {
        let service = ProfileService()
        Task {
            do {
                let profile = try await service.fetch(with: .email(email))
                // TODO: This should be updated with profile.id, which will be added in the future
                analytics.setUserName(profile.hash)
                analytics.track(WelcomeScreenEvent.authSuccess)
                displayName = profile.displayName
            } catch {
                displayName = error.localizedDescription
                analytics.track(WelcomeScreenEvent.authFailed(with: error.localizedDescription))
            }
        }
    }
}
