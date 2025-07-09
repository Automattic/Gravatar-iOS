import SwiftUI

class ShareFieldsModel: ObservableObject {
    @AppStorage("shareEmail")
    var email: Bool = true
    @AppStorage("sharePhone")
    var phone: Bool = true
    @AppStorage("shareContactForm")
    var contactForm: Bool = true
}
