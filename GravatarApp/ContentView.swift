import Gravatar
import SwiftUI

struct ContentView: View {
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
            }
            .buttonStyle(.borderedProminent)
            Text("Display Name:").padding(.top)
            Text(displayName)
        }
        .padding()
    }

    func fetchProfile() {
        let service = ProfileService()
        Task {
            do {
                let profile = try await service.fetch(with: .email(email))
                displayName = profile.displayName
            } catch {
                displayName = error.localizedDescription
            }
        }
    }
}

#Preview {
    ContentView()
}
