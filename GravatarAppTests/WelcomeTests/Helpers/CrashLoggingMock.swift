@testable import GravatarApp

class CrashLoggingMock: CrashLoggingType {
    var isEnabled: Bool = false
    var setNeedsDataRefreshCalled = false
    var loggedError: (Error, [String: Any]?)?

    func stopLogging() {
        isEnabled = false
    }

    func startLogging() throws {
        isEnabled = true
    }

    func setNeedsDataRefresh() {
        setNeedsDataRefreshCalled = true
    }

    func logError(_ error: any Error, userInfo: [String: Any]?) {
        loggedError = (error, userInfo)
    }
}
