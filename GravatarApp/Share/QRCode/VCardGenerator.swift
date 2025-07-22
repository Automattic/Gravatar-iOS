import Foundation
import Gravatar

struct VCardModel {
    let firstName: String
    let lastName: String
    let fullName: String
    let displayName: String
    let organization: String
    let jobTitle: String
    let phoneNumber: String
    let email: String
    let profileURL: String

    func generateVCard() -> String {
        vCard(self)
    }
}

private func vCard(_ model: VCardModel) -> String {
    """
    BEGIN:VCARD
    VERSION:4.0
    PRODID:Gravatar iOS
    N:\(model.lastName);\(model.firstName);
    FN:\(model.displayName)
    NICKNAME:\(model.displayName)
    ORG:\(model.organization)
    TITLE:\(model.jobTitle)
    TEL:\(model.phoneNumber)
    EMAIL:\(model.email)
    URL:\(model.profileURL)
    END:VCARD
    """
}
