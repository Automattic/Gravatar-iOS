import Foundation
import SwiftUI

@main
struct AppEntryPoint {
    static func main() {
        #if DEBUG
        guard isProduction() else {
            TestApp.main()
            return
        }
        #endif

        GravatarAppApp.main()
    }

    #if DEBUG
    private static func isProduction() -> Bool {
        NSClassFromString("XCTestCase") == nil
    }
    #endif
}

#if DEBUG
struct TestApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Unit Tests")
                .font(.largeTitle)
                .configureOAuth(
                    clientID: Secrets.clientID,
                    clientSecret: Secrets.clientSecret,
                    redirectURI: Secrets.redirectURI
                )
        }
    }
}
#endif
