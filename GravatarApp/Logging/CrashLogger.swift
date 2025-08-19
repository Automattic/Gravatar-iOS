import AutomatticRemoteLogging
import SwiftData

final class CrashLogger {
    private let crashLogging: CrashLoggingType
    private let dataProvider: AppCrashLoggingDataProvider

    init(crashLogging: CrashLoggingType? = nil, context: ModelContext, userDefaults: UserDefaults = .standard) {
        // ⚠️ WARNING: Remove next line before merging
        userDefaults.set(true, forKey: CrashLogging.forceCrashLoggingKey)
        self.dataProvider = AppCrashLoggingDataProvider(userDefaults: userDefaults, context: context)

        self.crashLogging = crashLogging ?? CrashLogging(
            dataProvider: dataProvider,
        )
    }

    #if DEBUG
    func crash() {
        crashLogging.crash()
    }
    #endif

    func start() {
        guard !dataProvider.userHasOptedOut else { return }

        do {
            try crashLogging.startLogging()
        } catch {
            print("⚠️ Crash logging failed to start: \(error)")
        }
    }

    func optOutChanged() {
        dataProvider.userHasOptedOut ? crashLogging.stopLogging() : start()
        refreshUser()
    }

    func refreshUser() {
        guard crashLogging.isEnabled else { return }
        crashLogging.setNeedsDataRefresh()
    }
}

private struct AppCrashLoggingDataProvider: CrashLoggingDataProvider {
    let sentryDSN = Secrets.sentryDSN
    let userDefaults: UserDefaults
    let context: ModelContext

    var userHasOptedOut: Bool {
        !PrivacySettingsUserSelection(userDefaults: userDefaults).shareCrashReports
    }

    var shouldEnableAutomaticSessionTracking: Bool {
        PrivacySettingsUserSelection(userDefaults: userDefaults).shareCrashReports
    }

    var currentUser: TracksUser? {
        guard
            let currentUserHash = userDefaults.string(forKey: .Gravatar.currentUserKey)
        else { return nil }

        let descriptor = FetchDescriptor<ProfileStore>(predicate: #Predicate { $0.userHash == currentUserHash })

        guard let profile = try? context.fetch(descriptor).first?.profile else { return nil }
        let userID = profile.userId.flatMap { "\($0)" }

        return TracksUser(userID: userID, email: nil, username: profile.userLogin)
    }

    var buildType: String {
        #if DEBUG
        return "debug"
        #elseif PROTOTYPE
        return "prototype"
        #else
        return "release"
        #endif
    }

    init(userDefaults: UserDefaults = .standard, context: ModelContext) {
        self.userDefaults = userDefaults
        self.context = context
    }
}
