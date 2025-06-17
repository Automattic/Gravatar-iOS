import OAuth
import SwiftUI

@main
struct GravatarAppApp: App {
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .configureOAuth(clientID: "", redirectURI: "")
        }
    }
}
