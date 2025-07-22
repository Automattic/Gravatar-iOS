import Foundation
import Gravatar

extension Profile {
    static let full: Profile = {
        let profile: Profile = try! Bundle.fullProfileJsonData.decode()
        return profile
    }()

    static var clean: Profile {
        with(displayName: "cleanprofile", location: "", description: "", jobTitle: "", company: "")
    }

    static func with(
        displayName: String = "John Appleseed",
        location: String = "Atlanta GA",
        description: String = "I'm a beach tennis player who enjoys the dynamic challenges and camaraderie of the game on the sand.",
        jobTitle: String = "Engineer",
        company: String = "A company"
    ) -> Profile {
        let json =
            """
            {
                "hash": "somehash",
                "display_name": "\(displayName)",
                "profile_url": "https://gravatar.com/notreal",
                "avatar_url": "https://2.gravatar.com/avatar/hashhash",
                "avatar_alt_text": "",
                "location": "\(location)",
                "description": "\(description)",
                "job_title": "\(jobTitle)",
                "company": "\(company)",
                "verified_accounts": [],
                "pronunciation": "",
                "pronouns": "",
                "timezone": "",
                "languages": [
                    {
                        "code": "en",
                        "name": "English",
                        "is_primary": true,
                        "order": 0
                    }
                ],
                "first_name": "",
                "last_name": "",
                "is_organization": false,
                "number_verified_accounts": 1,
                "last_profile_edit": "2024-09-04T11:54:32Z",
                "registration_date": "2024-05-28T10:40:22Z"
            }
            """
        let profile: Profile = try! json.data(using: .utf8)!.decode()
        return profile
    }
}
