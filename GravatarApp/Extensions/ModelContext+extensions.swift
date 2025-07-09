import SwiftData

extension ModelContext {
    func saveNow() {
        do {
            try save()
        } catch {
            print("Error trying to save the context: \(error)")
        }
    }
}

extension ModelContext {
    @MainActor
    static var testContext: ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: ProfileStore.self, configurations: config)
        return container.mainContext
    }
}
