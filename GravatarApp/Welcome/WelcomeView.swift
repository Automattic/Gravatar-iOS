import SwiftUI
import OAuth

struct WelcomeView: View {
    @Environment(\.oauthManager) var oauthManager
    @State var oauthError: OAuthError?

    var body: some View {
        VStack {
            Spacer()
            Text("Gravatar")
                .font(.largeTitle)
            Spacer()
            Button("Login") {
                Task {
                    await requestOAuthSession()
                }
            }.buttonStyle(.borderedProminent)
            Spacer()
            if let oauthError {
                Text(oauthError.localizedDescription)
                Spacer()
            }
        }
    }

    func requestOAuthSession() async {
        do {
            try await oauthManager.requestSession(
                with: .init("etoledom2@icloud.com")
            )
        } catch {
            oauthError = error
        }
    }
}

#Preview {
    WelcomeView()
}
