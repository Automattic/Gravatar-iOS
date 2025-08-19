import Analytics
import OAuth
import SwiftData
import SwiftUI

struct GravatarAppApp: App {
    @State private var unrecoberableError: Error?
    @StateObject private var welcomeViewModel: WelcomeViewModel

    init() {
        let settings = PrivacySettingsUserSelection()
        Analytics.setPushEventsToRemote(settings.shareAnalytics)

        do {
            let context = try ModelContext(ModelContainer(for: ProfileStore.self))
            _welcomeViewModel = .init(wrappedValue: .init(context: context, crashLogger: CrashLogger(context: context)))
        } catch {
            print("Error creating model context: \(error)")
            resetSwiftDataStore()
            let context = try! ModelContext(ModelContainer(for: ProfileStore.self))
            _welcomeViewModel = .init(wrappedValue: .init(context: context, crashLogger: CrashLogger(context: context)))
        }
    }

    var body: some Scene {
        WindowGroup {
            WelcomeView(viewModel: welcomeViewModel)
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

private func resetSwiftDataStore() {
    let fileManager = FileManager.default
    let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")

    if fileManager.fileExists(atPath: storeURL.path) {
        do {
            try fileManager.removeItem(at: storeURL)
            print("✅ SwiftData store deleted.")
        } catch {
            print("❌ Error deleting SwiftData store: \(error)")
        }
    } else {
        print("❌ Error deleting SwiftData store: Could not find store file.")
    }
}
