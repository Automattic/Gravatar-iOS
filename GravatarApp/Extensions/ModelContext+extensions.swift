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
        .testContainer.mainContext
    }

    @MainActor
    static var testContainer: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: ProfileStore.self, configurations: config)
    }
}
