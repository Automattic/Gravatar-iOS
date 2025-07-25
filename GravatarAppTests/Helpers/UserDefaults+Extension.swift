import Foundation

extension UserDefaults {
    static let testSuiteName = "test.GravatarApp"
    static let testUserDefaults = UserDefaults(suiteName: testSuiteName)!

    static func deleteTestData() {
        UserDefaults.testUserDefaults.removePersistentDomain(forName: UserDefaults.testSuiteName)
    }
}
