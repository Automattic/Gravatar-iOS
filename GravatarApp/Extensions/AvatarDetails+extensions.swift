import Foundation
import Gravatar

extension AvatarDetails {
    func url(withSize size: String) -> String {
        let components = URLComponents(string: imageURL)
        if let newURL = components?.replacingQueryItem(name: "size", value: size).string {
            return newURL
        }
        return imageURL
    }

    var isSelected: Bool {
        selected ?? false
    }
}
