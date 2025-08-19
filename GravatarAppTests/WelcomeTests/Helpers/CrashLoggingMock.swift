@testable import GravatarApp

class CrashLoggingMock: CrashLoggingType {
    var isEnabled: Bool = false
    var setNeedsDataRefreshCalled = false
    var loggedError: (Error, [String: String])?

    func stopLogging() {
        isEnabled = false
    }

    func startLogging() throws {
        isEnabled = true
    }

    func setNeedsDataRefresh() {
        setNeedsDataRefreshCalled = true
    }

    func logError(_ error: Error, tags: [String: String]) {
        loggedError = (error, tags)
    }
}
