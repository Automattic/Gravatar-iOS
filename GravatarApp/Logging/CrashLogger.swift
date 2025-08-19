import AutomatticRemoteLogging
import SwiftData

final class CrashLogger {
    enum Key {
        static let errorTypeKey = "error_type"
        static let errorTagKey = "error_tag"
    }

    private let crashLogging: CrashLoggingType
    private let dataProvider: AppCrashLoggingDataProvider

    init(crashLogging: CrashLoggingType? = nil, context: ModelContext, userDefaults: UserDefaults = .standard) {
        self.dataProvider = AppCrashLoggingDataProvider(userDefaults: userDefaults, context: context)

        self.crashLogging = crashLogging ?? CrashLogging(
            dataProvider: dataProvider,
        )
    }

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

    func logError(_ error: Error, tags: [String: String] = [:]) {
        crashLogging.logError(error, tags: tags)
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
