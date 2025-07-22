import SwiftUI

class ShareFieldsSelectionStore: ObservableObject {
    @AppStorage("shareEmail")
    private var emailStore: Bool = true
    @Published var email: Bool = true {
        didSet { emailStore = email }
    }

    @AppStorage("sharePhone")
    private var phoneStore: Bool = true
    @Published var phone: Bool = true {
        didSet { phoneStore = phone }
    }

    @AppStorage("shareName")
    private var nameStore: Bool = true
    @Published var name: Bool = true {
        didSet { nameStore = name }
    }

    @AppStorage("shareLocation")
    private var locationStore: Bool = true
    @Published var location: Bool = true {
        didSet { locationStore = location }
    }

    @AppStorage("shareJobTitle")
    private var jobTitleStore: Bool = true
    @Published var jobTitle: Bool = true {
        didSet { jobTitleStore = jobTitle }
    }

    @AppStorage("shareCompany")
    private var companyStore: Bool = true
    @Published var company: Bool = true {
        didSet { companyStore = company }
    }

    @AppStorage("shareDescription")
    private var descriptionStore: Bool = true
    @Published var description: Bool = true {
        didSet { descriptionStore = description }
    }

    @AppStorage("shareProfileURL")
    private var profileURLStore: Bool = true
    @Published var profileURL: Bool = true {
        didSet { profileURLStore = profileURL }
    }

    init() {
        email = emailStore
        phone = phoneStore
        location = locationStore
        name = nameStore
        jobTitle = jobTitleStore
        company = companyStore
        description = descriptionStore
        profileURL = profileURLStore
    }
}
