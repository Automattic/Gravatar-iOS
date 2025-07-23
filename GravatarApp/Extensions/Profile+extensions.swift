import Foundation
import Gravatar

#if DEBUG
extension Profile {
    static var testProfile: Profile {
        let rawProfile: [String: Any] = [
            "hash": "hash",
            "display_name": "John Appleseed",
            "first_name": "John",
            "last_name": "Appleseed",
            "profile_url": "https://gravatar.com/johnappleseed",
            "avatar_url": "",
            "avatar_alt_text": "",
            "location": "Vestal, NY",
            "description": "Some long description which will hopefully generate multiline labels all around the app.",
            "job_title": "Software Engineer",
            "company": "Automattic",
            "verified_accounts": [
                [
                    "service_type": "wp",
                    "service_label": "WordPress",
                    "service_icon": "",
                    "url": "https://wordpress.com/mysite",
                    "is_hidden": false,
                ],
            ],
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

    var fullName: String? {
        [firstName, lastName].compactMap(\.self).filter { !$0.isEmpty }.joined(separator: " ")
    }
}
