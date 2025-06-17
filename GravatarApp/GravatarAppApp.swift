import SwiftUI
import OAuth

@main
struct GravatarAppApp: App {
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .configureOAuth(clientID: "", redirectURI: "")
        }
    }
}
