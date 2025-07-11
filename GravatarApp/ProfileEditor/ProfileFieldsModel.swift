import Gravatar
import SwiftUI

class ProfileFieldsModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var aboutMe: String = ""
    @Published var pronunciation: String = ""
    @Published var pronouns: String = ""
    @Published var location: String = ""
    @Published var jobTitle: String = ""
    @Published var company: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""

    init() {}

    init(profile: Profile) {
        self.displayName = profile.displayName
        self.aboutMe = profile.description
        self.pronunciation = profile.pronunciation
        self.pronouns = profile.pronouns
        self.location = profile.location
        self.jobTitle = profile.jobTitle
        self.company = profile.company
        self.firstName = profile.firstName ?? ""
        self.lastName = profile.lastName ?? ""
    }

    init(
        displayName: String,
        aboutMe: String,
        pronunciation: String,
        pronouns: String,
        location: String,
        jobTitle: String,
        company: String,
        firstName: String,
        lastName: String
    ) {
        self.displayName = displayName
        self.aboutMe = aboutMe
        self.pronunciation = pronunciation
        self.pronouns = pronouns
        self.location = location
        self.jobTitle = jobTitle
        self.company = company
        self.firstName = firstName
        self.lastName = lastName
    }

    func trimWhitespaces() {
        displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        aboutMe = aboutMe.trimmingCharacters(in: .whitespacesAndNewlines)
        pronunciation = pronunciation.trimmingCharacters(in: .whitespacesAndNewlines)
        pronouns = pronouns.trimmingCharacters(in: .whitespacesAndNewlines)
        location = location.trimmingCharacters(in: .whitespacesAndNewlines)
        jobTitle = jobTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        company = company.trimmingCharacters(in: .whitespacesAndNewlines)
        firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func updateRequest() -> UpdateProfileRequest {
        UpdateProfileRequest(
            firstName: firstName,
            lastName: lastName,
            displayName: displayName,
            description: aboutMe,
            pronunciation: pronunciation,
            pronouns: pronouns,
            location: location,
            jobTitle: jobTitle,
            company: company
        )
    }

    func isEqual(to profile: Profile) -> Bool {
        firstName == profile.firstName
            && lastName == profile.lastName
            && displayName == profile.displayName
            && aboutMe == profile.description
            && pronunciation == profile.pronunciation
            && pronouns == profile.pronouns
            && location == profile.location
            && jobTitle == profile.jobTitle
            && company == profile.company
    }

    func value(for field: ProfileField) -> String? {
        switch field {
        case .displayName:
            displayName
        case .aboutMe:
            aboutMe
        case .pronunciation:
            pronunciation
        case .pronouns:
            pronouns
        case .location:
            location
        case .firstName:
            firstName
        case .lastName:
            lastName
        case .company:
            company
        case .jobTitle:
            jobTitle
        }
    }

    func setValue(_ value: String, for field: ProfileField) {
        switch field {
        case .displayName:
            displayName = value
        case .aboutMe:
            aboutMe = value
        case .pronunciation:
            pronunciation = value
        case .pronouns:
            pronouns = value
        case .location:
            location = value
        case .firstName:
            firstName = value
        case .lastName:
            lastName = value
        case .company:
            company = value
        case .jobTitle:
            jobTitle = value
        }
    }
}
