import Gravatar
import Foundation

extension ImageSize {
    static var preferredSize: ImageSize {
        .pixels(256)
    }
}

extension AvatarURL {
    static func preferredURL(for hash: String) -> URL? {
        AvatarURL(with: .hashID(hash), options: .init(preferredSize: .preferredSize))?.url
    }
}
