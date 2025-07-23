import Foundation

extension UserDefaults {
    /// Return the `defaultValue` if the value doesn't exist in the UserDefaults.
    func bool(forKey key: String, default defaultValue: Bool) -> Bool {
        object(forKey: key) as? Bool ?? defaultValue
    }
}
