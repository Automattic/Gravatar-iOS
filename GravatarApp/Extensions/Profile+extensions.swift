import Foundation
import Gravatar

#if DEBUG
extension Profile {
    static var testProfile: Profile {
        let rawProfile: [String: Any] = [
            "hash": "hash",
            "display_name": "John Appleseed",
            "profile_url": "https://gravatar.com/johnappleseed",
            "avatar_url": "",
            "avatar_alt_text": "",
            "location": "Vestal, NY",
            "description": "",
            "job_title": "Software Engineer",
            "company": "Automattic",
            "verified_accounts": [],
            "pronunciation": "",
            "pronouns": "",
        ]
        let rawData = try! JSONSerialization.data(withJSONObject: rawProfile, options: [])
        return try! JSONDecoder().decode(Profile.self, from: rawData)
    }
}
#endif

extension Profile {
    var professionFullDescription: String? {
        [jobTitle, company].filter { !$0.isEmpty }.joined(separator: ", ")
    }
}
