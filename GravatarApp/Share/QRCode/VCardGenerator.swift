import Foundation
import Gravatar

struct VCardModel {
    struct URL {
        let label: String
        let value: String
    }

    let firstName: String
    let lastName: String
    let fullName: String
    let displayName: String
    let organization: String
    let jobTitle: String
    let location: String
    let phoneNumber: String
    let email: String
    let profileURL: String
    let description: String
    let avatarData: Data?
    let accounts: [URL]

    func generateVCard() -> String {
        vCard(self)
    }
}

extension [VerifiedAccount] {
    func map() -> [VCardModel.URL] {
        self.compactMap {
            .init(label: $0.serviceLabel, value: $0.url)
        }
    }
}

private func vCard(_ model: VCardModel) -> String {
    """
    BEGIN:VCARD
    VERSION:3.0
    PRODID:Gravatar iOS
    N:\(model.lastName);\(model.firstName);
    FN:\(model.displayName)
    NICKNAME:\(model.displayName)
    ORG:\(model.organization)
    TITLE:\(model.jobTitle)
    TEL:\(model.phoneNumber)
    EMAIL:\(model.email)
    URL:\(model.profileURL)
    \(locationFields(model.location))
    \(urlFields(with: model.accounts))
    NOTE:\(model.description)
    PHOTO;ENCODING=b;TYPE=JPEG:\(model.avatarData?.base64EncodedString() ?? "")
    END:VCARD
    """
}

private func locationFields(_ location: String) -> String {
    guard !location.isEmpty else {
        return ""
    }
    return "ADR;CHARSET=UTF-8;TYPE=HOME:;;;\(location);;;"
}

private func urlFields(with accounts: [VCardModel.URL]) -> String {
    accounts.compactMap { url in
        "URL;TYPE=\"\(url.label)\":\(url.value)"
    }.joined(separator: "\n")
}
