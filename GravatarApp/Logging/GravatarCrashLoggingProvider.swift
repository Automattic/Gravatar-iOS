import AutomatticRemoteLogging

actor GravatarCrashLogger {
    static let shared = GravatarCrashLogger()
    private let crashLogging: CrashLogging

    private init() {
        self.crashLogging = CrashLogging(
            dataProvider: GravatarCrashLoggingDataProvider()
        )
    }

    func start() {
        // TEMPORARY
        UserDefaults.standard.set(true, forKey: "force-crash-logging")

        do {
            _ = try crashLogging.start()
            print("Crash logging started!")
        } catch {
            print("⚠️ Crash logging failed to start: \(error)")
        }
    }

    // TEMPORARY TEST
    func crash() {
        self.crashLogging.crash()
    }
}

struct GravatarCrashLoggingDataProvider: CrashLoggingDataProvider {
    let sentryDSN = Secrets.sentryDSN
    let userHasOptedOut = false
    let shouldEnableAutomaticSessionTracking = true

    // TODO: Add current user
    var currentUser: TracksUser? = nil

    var buildType: String {
        #if DEBUG
        return "debug"
        #elseif PROTOTYPE
        return "prototype"
        #else
        return "release"
        #endif
    }
}
