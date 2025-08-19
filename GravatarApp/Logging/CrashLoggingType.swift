import AutomatticRemoteLogging
import Sentry

protocol CrashLoggingType {
    var isEnabled: Bool { get }

    func startLogging() throws
    func stopLogging()
    func setNeedsDataRefresh()
    func logError(_ error: Error, tags: [String: String])
}

extension CrashLogging: CrashLoggingType {
    func stopLogging() {
        SentrySDK.close()
    }

    var isEnabled: Bool {
        SentrySDK.isEnabled
    }

    func startLogging() throws {
        _ = try self.start()
    }

    func logError(_ error: Error, tags: [String: String] = [:]) {
        logError(error, tags: tags, level: .error)
    }
}
