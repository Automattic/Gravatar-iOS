import AutomatticRemoteLogging
import Sentry

protocol CrashLoggingType {
    var isEnabled: Bool { get }

    #if DEBUG
    func crash()
    #endif

    func startLogging() throws
    func stopLogging()
    func setNeedsDataRefresh()
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
}
