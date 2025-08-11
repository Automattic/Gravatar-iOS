import Foundation

extension UserDefaults {
    static let testSuiteName = "test.GravatarApp"
    static let testUserDefaults = UserDefaults(suiteName: testSuiteName)!

    static func deleteTestData(named name: String = testSuiteName) {
        UserDefaults.testUserDefaults.removePersistentDomain(forName: name)
    }

    static func testUserDefaults(named name: String) -> UserDefaults {
        UserDefaults(suiteName: name)!
    }
}
