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

    func hasDifference(comparedTo profile: Profile) -> Bool {
        for field in ProfileField.allCases {
            if hasDifference(in: field, comparedTo: profile) {
                return true
            }
        }
        return false
    }

    func hasDifference(in field: ProfileField, comparedTo profile: Profile) -> Bool {
        switch field {
        case .displayName:
            displayName != profile.displayName
        case .location:
            location != profile.location
        case .company:
            company != profile.company
        case .aboutMe:
            aboutMe != profile.description
        case .firstName:
            firstName != (profile.firstName ?? "")
        case .lastName:
            lastName != (profile.lastName ?? "")
        case .pronouns:
            pronouns != profile.pronouns
        case .pronunciation:
            pronunciation != profile.pronunciation
        case .jobTitle:
            jobTitle != profile.jobTitle
        }
    }
}
