import SwiftUI
import UIKit
import Gravatar

struct AvatarImageModel: Hashable, Identifiable, Sendable {
    enum Source: Hashable {
        case remote(url: String)
        case local(image: UIImage)
    }

    enum State: Equatable, Hashable {
        case loaded
        case loading
        case error(supportsRetry: Bool, errorMessage: String)
    }

    let id: String
    let source: Source
    let isSelected: Bool
    let state: State
    let altText: String

    var url: URL? {
        guard case .remote(let url) = source else {
            return nil
        }

        return URL(string: url)
    }

    var localImage: Image? {
        guard case .local(let image) = source else {
            return nil
        }
        return Image(uiImage: image)
    }

    var localUIImage: UIImage? {
        guard case .local(let image) = source else {
            return nil
        }
        return image
    }

    init(id: String, source: Source, state: State, isSelected: Bool, altText: String) {
        self.id = id
        self.source = source
        self.state = state
        self.isSelected = isSelected
        self.altText = altText
    }

    func updating(_ callback: (inout Builder) -> Void) -> AvatarImageModel {
        var builder = Builder(self)
        callback(&builder)
        return builder.build()
    }

    func accessibilityLabel(altText: String) -> String {
        String(
            format: NSLocalizedString(
                "Avatar.Accessibility.AvatarButton.Label",
                value: "Avatar Image. %@",
                comment: "Accessibility label spoken outloud by VoiceOver when an avatar is selected. The '%@' is the Alt text of the avatar image."
            ),
            altText
        )
    }
}

extension AvatarImageModel {
    init(with avatar: AvatarDetails) {
        id = avatar.imageID
        let avatarGridItemSize = Int(.maxAvatarWidth * UITraitCollection.current.displayScale)
        source = .remote(url: avatar.url(withSize: String(avatarGridItemSize)))
        state = .loaded
        isSelected = avatar.isSelected
        altText = avatar.altText
    }
}

extension AvatarImageModel {
    struct Builder {
        var id: String
        var source: Source
        var isSelected: Bool
        var state: State
        var altText: String

        fileprivate init(_ model: AvatarImageModel) {
            self.id = model.id
            self.source = model.source
            self.isSelected = model.isSelected
            self.state = model.state
            self.altText = model.altText
        }

        fileprivate func build() -> AvatarImageModel {
            .init(id: id, source: source, state: state, isSelected: isSelected, altText: altText)
        }
    }
}

extension AvatarImageModel {
    /// This is meant to be used in previews and unit tests only.
    static func preview_init(id: String, source: Source, state: State = .loaded, isSelected: Bool = false) -> Self {
        AvatarImageModel(id: id, source: source, state: state, isSelected: isSelected, altText: "")
    }
}
