import Foundation
import SwiftUI

enum AvatarAction: Identifiable {
    case select
    case share
    case delete
    case playground
    // case altText

    var id: String {
        switch self {
        case .select: "select"
        case .share: "share"
        case .delete: "delete"
        case .playground: "playground"
            // case .altText: "altText"
        }
    }

    var icon: String {
        switch self {
        case .select:
            "checkmark.circle"
        case .delete:
            "trash"
        case .share:
            "square.and.arrow.up"
        case .playground:
            "apple.image.playground"
            /* case .altText:
                 Image(systemName: "text.below.photo")
             */
        }
    }

    var attribures: UIMenuElement.Attributes {
        switch self {
        case .delete: .destructive
        default: []
        }
    }

    var localizedTitle: String {
        switch self {
        case .select:
            NSLocalizedString(
                "AvatarPicker.AvatarAction.select",
                value: "Select",
                comment: "An option in the avatar menu that selects the avatar"
            )
        case .delete:
            NSLocalizedString(
                "AvatarPicker.AvatarAction.delete",
                value: "Delete",
                comment: "An option in the avatar menu that deletes the avatar"
            )
        case .share:
            NSLocalizedString(
                "AvatarPicker.AvatarAction.share",
                value: "Share...",
                comment: "An option in the avatar menu that shares the avatar"
            )
        case .playground:
            NSLocalizedString(
                "SystemImagePickerView.Source.Playground.title",
                value: "Playground",
                comment: "An option to show the image playground"
            )
            /* case .altText:
                NSLocalizedString(
                    "AvatarPicker.AvatarAction.altText",
                    value: "Alt Text",
                    comment: "An option in the avatar menu that edits the avatar's Alt Text."
                )
             */
        }
    }

    var role: ButtonRole? {
        switch self {
        case .delete:
            .destructive
        case .share, .playground, /* .altText, */ .select:
            nil
        }
    }
}
