#if DEBUG
import Foundation
import Gravatar

extension Profile {
    static var testProfile: Profile {
        let rawProfile: [String: Any] = [
            "hash": "hash",
            "display_name": "John Appleseed",
            "profile_url": "",
            "avatar_url": "",
            "avatar_alt_text": "",
            "location": "",
            "description": "",
            "job_title": "",
            "company": "",
            "verified_accounts": [],
            "pronunciation": "",
            "pronouns": "",
        ]
        let rawData = try! JSONSerialization.data(withJSONObject: rawProfile, options: [])
        return try! JSONDecoder().decode(Profile.self, from: rawData)
    }
}
#endif
