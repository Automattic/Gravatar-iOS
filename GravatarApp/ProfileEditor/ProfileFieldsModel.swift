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
    @Published var cellPhone: String = ""
    @Published var contactEmail: String = ""

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
        self.cellPhone = profile.contactInfo?.cellPhone ?? ""
        self.contactEmail = profile.contactInfo?.email ?? ""
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
        lastName: String,
        cellPhone: String,
        contactEmail: String
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
        self.cellPhone = cellPhone
        self.contactEmail = contactEmail
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
            company: company,
            cellPhone: cellPhone,
            contactEmail: contactEmail
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
            && cellPhone == profile.contactInfo?.cellPhone
            && contactEmail == profile.contactInfo?.email
    }
}
