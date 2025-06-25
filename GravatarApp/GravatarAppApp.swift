import OAuth
import SwiftUI

@main
struct GravatarAppApp: App {
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .configureOAuth(
                    clientID: Secrets.clientID,
                    clientSecret: Secrets.clientSecret,
                    redirectURI: Secrets.redirectURI
                )
                .onAppear {
                    let appearance = UITabBarAppearance()
                    appearance.configureWithDefaultBackground()
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
        }
    }
}
