import Foundation
import Gravatar

extension Profile {

    static let full: Profile = {
        let profile: Profile = try! Bundle.fullProfileJsonData.decode()
        return profile
    }()

}
