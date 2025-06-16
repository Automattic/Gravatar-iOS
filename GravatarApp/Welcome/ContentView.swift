import SwiftUI
import Gravatar
import Analytics

struct ContentView: View {
    @Environment(\.analytics) var analytics

    @State private var displayName: String = ""
    @State private var email: String = ""

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Gravatar email address:")
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }

            Button("Fetch profile") {
                fetchProfile()
                analytics.track(WelcomeScreenEvent.authButtonPressed)
            }
            .buttonStyle(.borderedProminent)
            Text("Display Name:")
                .padding(.top)
            Text(displayName)
        }
        .padding()
    }

    func fetchProfile() {
        let service = ProfileService()
        Task {
            do {
                let profile = try await service.fetch(with: .email(email))
                analytics.setUserId(email)
                analytics.track(WelcomeScreenEvent.authSuccess)
                displayName = profile.displayName
            } catch {
                displayName = error.localizedDescription
                analytics.track(WelcomeScreenEvent.authFailed(with: error.localizedDescription))
            }
        }
    }
}

#Preview {
    ContentView()
}
