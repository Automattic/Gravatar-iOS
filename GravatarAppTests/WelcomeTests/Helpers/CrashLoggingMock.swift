@testable import GravatarApp

class CrashLoggingMock: CrashLoggingType {
    var isEnabled: Bool = false
    var setNeedsDataRefreshCalled = false

    func stopLogging() {
        isEnabled = false
    }

    func startLogging() throws {
        isEnabled = true
    }

    func setNeedsDataRefresh() {
        setNeedsDataRefreshCalled = true
    }
}
