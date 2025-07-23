import Foundation

extension UserDefaults {
    static let testSuiteName = "test.GravatarApp"
    static let testUserDefaults = UserDefaults(suiteName: testSuiteName)!
}
