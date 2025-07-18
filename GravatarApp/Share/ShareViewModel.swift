import SwiftUI

class ShareViewModel: ObservableObject {
    @Published var contactPreviewURL: URL?

    let userSession: UserSession

    @AppStorage("storedUserEmail")
    var storedUserEmail: String = ""

    @AppStorage("storedPhoneNumber")
    var storedPhoneNumber: String = ""

    @Published var share: ShareFieldsModel = .init()

    init(userSession: UserSession) {
        self.userSession = userSession
    }

    func previewVCard() {
        let data = vcardExample.data(using: .utf8)!
        let tempDirectory = FileManager.default.temporaryDirectory
        let url = tempDirectory.appendingPathComponent("contact.vcf")
        try! data.write(to: url)
        contactPreviewURL = url
    }
}

private let vcardExample: String =
    """
    BEGIN:VCARD
    VERSION:4.0
    N:Gump;Forrest;;Mr.;
    FN:Sheri Nom
    ORG:Sheri Nom Co.
    TITLE:Ultimate Warrior
    PHOTO;MEDIATYPE#image/gif:http://www.sherinnom.com/dir_photos/my_photo.gif
    TEL;TYPE#work,voice;VALUE#uri:tel:+1-111-555-1212
    TEL;TYPE#home,voice;VALUE#uri:tel:+1-404-555-1212
    ADR;TYPE#WORK;PREF#1;LABEL#"Normality\nBaytown, LA 50514\nUnited States of America":;;100 Waters Edge;Baytown;LA;50514;United States of America
    ADR;TYPE#HOME;LABEL#"42 Plantation St.\nBaytown, LA 30314\nUnited States of America":;;42 Plantation St.;Baytown;LA;30314;United States of America
    EMAIL:sherinnom@example.com
    REV:20080424T195243Z
    x-qq:21588891
    END:VCARD
    """
