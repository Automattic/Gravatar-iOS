import Gravatar
import SwiftUI
import Analytics

class ShareFieldsSelectionStore: ObservableObject {
    private let userDefaults: UserDefaults
    private let analytics: Analytics

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
        didSet {
            analytics.track(QRScreenEvents.fieldToggled(isOn: email, field: .email))
            userDefaults.set(email, forKey: Key.shareEmail)
        }
    }

    @Published var phone: Bool {
        didSet {
            analytics.track(QRScreenEvents.fieldToggled(isOn: phone, field: .phone))
            userDefaults.set(phone, forKey: Key.sharePhone)
        }
    }

    @Published var name: Bool {
        didSet {
            analytics.track(QRScreenEvents.fieldToggled(isOn: name, field: .name))
            userDefaults.set(name, forKey: Key.shareName)
        }
    }

    @Published var location: Bool {
        didSet {
            analytics.track(QRScreenEvents.fieldToggled(isOn: location, field: .location))
            userDefaults.set(location, forKey: Key.shareLocation)
        }
    }

    @Published var jobTitle: Bool {
        didSet {
            analytics.track(QRScreenEvents.fieldToggled(isOn: jobTitle, field: .jobTitle))
            userDefaults.set(jobTitle, forKey: Key.shareJobTitle)
        }
    }

    @Published var company: Bool {
        didSet {
            analytics.track(QRScreenEvents.fieldToggled(isOn: company, field: .company))
            userDefaults.set(company, forKey: Key.shareCompany)
        }
    }

    @Published var description: Bool {
        didSet {
            analytics.track(QRScreenEvents.fieldToggled(isOn: description, field: .aboutMe))
            userDefaults.set(description, forKey: Key.shareDescription)
        }
    }

    @Published var profileURL: Bool {
        didSet {
            analytics.track(QRScreenEvents.fieldToggled(isOn: profileURL, field: .profileURL))
            userDefaults.set(profileURL, forKey: Key.shareProfileURL)
        }
    }

    func account(_ verifiedAccount: VerifiedAccount) -> Bool {
        userDefaults.bool(forKey: verifiedAccount.url, default: true)
    }

    func set(_ verifiedAccount: VerifiedAccount, to value: Bool) {
        analytics.track(QRScreenEvents.fieldToggled(isOn: value, field: .verifiedAccount(verifiedAccount.serviceType)))
        userDefaults.set(value, forKey: verifiedAccount.url)
        objectWillChange.send()
    }

    init(userDefaults: UserDefaults = .standard, analytics: Analytics = .shared) {
        self.userDefaults = userDefaults
        self.analytics = analytics

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
