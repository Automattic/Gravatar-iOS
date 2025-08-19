import Foundation

extension Notification.Name {
    static let sessionExpired = Notification.Name("SessionExpiredNotification")
    static let showToast = Notification.Name("ShowToastNotification")
    static let signOut = Notification.Name("SignOutNotification")
    static let deleteAccount = Notification.Name("DeleteAccountNotification")
    static let crashLoggerOptOutChanged = Notification.Name("CrashLoggerOptOutChanged")
}
