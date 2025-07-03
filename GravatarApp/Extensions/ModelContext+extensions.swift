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
