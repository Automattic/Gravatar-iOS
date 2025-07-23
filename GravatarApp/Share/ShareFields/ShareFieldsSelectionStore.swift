import Gravatar
import SwiftUI

class ShareFieldsSelectionStore: ObservableObject {
    private let userDefaults: UserDefaults

    private enum Key {
        static let shareEmail = "shareEmail"
        static let sharePhone = "sharePhone"
        static let shareName = "shareName"
        static let shareLocation = "shareLocation"
        static let shareJobTitle = "shareJobTitle"
        static let shareCompany = "shareCompany"
        static let shareDescription = "shareDescription"
        static let shareProfileURL = "shareProfileURL"
    }

    @Published var email: Bool {
        didSet { userDefaults.set(email, forKey: Key.shareEmail) }
    }

    @Published var phone: Bool {
        didSet { userDefaults.set(phone, forKey: Key.sharePhone) }
    }

    @Published var name: Bool {
        didSet { userDefaults.set(name, forKey: Key.shareName) }
    }

    @Published var location: Bool {
        didSet { userDefaults.set(location, forKey: Key.shareLocation) }
    }

    @Published var jobTitle: Bool {
        didSet { userDefaults.set(jobTitle, forKey: Key.shareJobTitle) }
    }

    @Published var company: Bool {
        didSet { userDefaults.set(company, forKey: Key.shareCompany) }
    }

    @Published var description: Bool {
        didSet { userDefaults.set(description, forKey: Key.shareDescription) }
    }

    @Published var profileURL: Bool {
        didSet { userDefaults.set(profileURL, forKey: Key.shareProfileURL) }
    }

    func account(_ verifiedAccount: VerifiedAccount) -> Bool {
        userDefaults.bool(forKey: verifiedAccount.url, default: true)
    }

    func set(_ verifiedAccount: VerifiedAccount, to value: Bool) {
        userDefaults.set(value, forKey: verifiedAccount.url)
        objectWillChange.send()
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        email = userDefaults.bool(forKey: Key.shareEmail, default: true)
        phone = userDefaults.bool(forKey: Key.sharePhone, default: true)
        name = userDefaults.bool(forKey: Key.shareName, default: true)
        location = userDefaults.bool(forKey: Key.shareLocation, default: true)
        jobTitle = userDefaults.bool(forKey: Key.shareJobTitle, default: true)
        company = userDefaults.bool(forKey: Key.shareCompany, default: true)
        description = userDefaults.bool(forKey: Key.shareDescription, default: true)
        profileURL = userDefaults.bool(forKey: Key.shareProfileURL, default: true)
    }
}

extension UserDefaults {
    /// Return the `defaultValue` if the value doesn't exist in the UserDefaults.
    func bool(forKey key: String, default defaultValue: Bool) -> Bool {
        object(forKey: key) as? Bool ?? defaultValue
    }
}
