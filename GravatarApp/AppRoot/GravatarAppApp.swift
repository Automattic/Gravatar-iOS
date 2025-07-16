import OAuth
import SwiftData
import SwiftUI

@main
struct GravatarAppApp: App {
    var modelContext: ModelContext
    @State private var unrecoberableError: Error?

    init() {
        do {
            self.modelContext = try ModelContext(ModelContainer(for: ProfileStore.self))
        } catch {
            print("Error creating model context: \(error)")
            resetSwiftDataStore()
            modelContext = try! ModelContext(ModelContainer(for: ProfileStore.self))
        }
    }

    var body: some Scene {
        WindowGroup {
            WelcomeView(modelContext: modelContext)
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

extension ProcessInfo {
    var isSnapshotTesting: Bool {
        environment["SNAPSHOT_TESTING"] == "1"
    }
}
