import OAuth
import SwiftData
import SwiftUI
import Analytics

@main
struct GravatarAppApp: App {
    var modelContext: ModelContext
    @State private var unrecoberableError: Error?
    @StateObject private var welcomeViewModel: WelcomeViewModel

    init() {
        Analytics.setPushEventsToRemote(false)
        do {
            let context = try ModelContext(ModelContainer(for: ProfileStore.self))
            self.modelContext = context
            _welcomeViewModel = .init(wrappedValue: .init(context: context))
        } catch {
            print("Error creating model context: \(error)")
            resetSwiftDataStore()
            let context = try! ModelContext(ModelContainer(for: ProfileStore.self))
            self.modelContext = context
            _welcomeViewModel = .init(wrappedValue: .init(context: context))
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
