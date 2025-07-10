import Foundation

enum ProfileField: Hashable {
    case displayName
    case aboutMe
    case pronunciation
    case pronouns
    case location
    case jobTitle
    case company
    case firstName
    case lastName

    var localizedTitle: String {
        switch self {
        case .displayName:
            ProfileEditLocalization.displayName
        case .aboutMe:
            ProfileEditLocalization.aboutMe
        case .pronunciation:
            ProfileEditLocalization.pronunciation
        case .pronouns:
            ProfileEditLocalization.pronouns
        case .location:
            ProfileEditLocalization.location
        case .jobTitle:
            ProfileEditLocalization.jobTitle
        case .company:
            ProfileEditLocalization.company
        case .firstName:
            ProfileEditLocalization.firstName
        case .lastName:
            ProfileEditLocalization.lastName
        }
    }
}
