import SwiftUI

class ShareViewModel: ObservableObject {
    let userSession: UserSession

    @Published var share: ShareFieldsModel = .init()

    init(userSession: UserSession) {
        self.userSession = userSession
    }
}
