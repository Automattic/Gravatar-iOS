import Foundation

enum ProfileEditLocalization {

    // MARK: Fields

    /// The user’s display name.
    static let displayName: String = {
        NSLocalizedString(
            "Profile.AboutInfoField.displayName",
            value: "Display Name",
            comment: "Label of a field that contains a user’s display name."
        )
    }()
    /// A short biography or description about the user.
    static let aboutMe: String = {
        NSLocalizedString(
            "Profile.AboutInfoField.aboutMe",
            value: "About Me",
            comment: "Label of a field that contains a short biography or description about the user."
        )
    }()
    /// A phonetic pronunciation of the user’s name.
    static let pronunciation: String = {
        NSLocalizedString(
            "Profile.AboutInfoField.pronunciation",
            value: "Pronunciation",
            comment: "Label of a field that contains a phonetic pronunciation of the user’s name."
        )
    }()
    /// The pronouns the user identifies with (e.g., she/her, they/them).
    static let pronouns: String = {
        NSLocalizedString(
            "Profile.AboutInfoField.pronouns",
            value: "Pronouns",
            comment: "Label of a field that contains the pronouns the user identifies with (e.g., she/her, they/them)."
        )
    }()
    /// The user's geographic location.
    static let location: String = {
        NSLocalizedString(
            "Profile.AboutInfoField.location",
            value: "Location",
            comment: "Label of a field that contains the user's geographic location."
        )
    }()
    /// The user's current job title or role.
    static let jobTitle: String = {
        NSLocalizedString(
            "Profile.AboutInfoField.jobTitle",
            value: "Job Title",
            comment: "Label of a field that contains the user's current job title or role."
        )
    }()
    /// The company or organization the user is affiliated with.
    static let company: String = {
        NSLocalizedString(
            "Profile.AboutInfoField.company",
            value: "Company",
            comment: "Label of a field that contains the company or organization the user is affiliated with."
        )
    }()
    /// User's first name. This is only provided in authenticated API requests.
    static let firstName: String = {
        NSLocalizedString(
            "Profile.AboutInfoField.firstName",
            value: "First Name",
            comment: "Label of a field that contains a user’s first name."
        )
    }()
    /// User's last name. This is only provided in authenticated API requests.
    static let lastName: String = {
        NSLocalizedString(
            "Profile.AboutInfoField.lastName",
            value: "Last Name",
            comment: "Label of a field that contains a user’s last name."
        )
    }()
    
    /// User's contact email.
    static let contactEmail: String = {
        NSLocalizedString(
            "Profile.AboutInfoField.contactEmail",
            value: "Email",
            comment: "Label of a field that contains a user’s email."
        )
    }()

    /// User's phone number.
    static let phone: String = {
        NSLocalizedString(
            "Profile.AboutInfoField.contactPhone",
            value: "Phone",
            comment: "Label of a field that contains a user’s phone number."
        )
    }()
    
    // MARK: Section headers
    
    static let nameSectionHeader: String = {
        NSLocalizedString(
            "Profile.Section.Name.header",
            value: "Name",
            comment: "Title of the name section in the profile editing screen."
        )
    }()

    static let aboutSectionHeader: String = {
        NSLocalizedString(
            "Profile.Section.About.header",
            value: "About",
            comment: "Title of the about section in the profile editing screen."
        )
    }()

    static let professionalSectionHeader: String = {
        NSLocalizedString(
            "Profile.Section.Professional.header",
            value: "Professional",
            comment: "Title of the professional/work info section in the profile editing screen."
        )
    }()
    
    static let contactSectionHeader: String = {
        NSLocalizedString(
            "Profile.Section.Contact.header",
            value: "Contact",
            comment: "Title of the contact info section in the profile editing screen."
        )
    }()
}
