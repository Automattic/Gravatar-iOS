import SwiftUI

class ShareFieldsModel: ObservableObject {
    @AppStorage("shareEmail")
    var email: Bool = true
    @AppStorage("sharePhone")
    var phone: Bool = true
    @AppStorage("shareContactForm")
    var contactForm: Bool = true

    @AppStorage("shareName")
    var name: Bool = true

    @AppStorage("shareLocation")
    var location: Bool = true

    @AppStorage("shareJobTitle")
    var jobTitle: Bool = true

    @AppStorage("shareOrganization")
    var organization: Bool = true

    @AppStorage("shareDescription")
    var description: Bool = true
}
