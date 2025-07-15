import SwiftUI

extension ContentLoadingErrorView {
    static func avatars(description: String = AvatarLoadingError.description, buttonAction: @escaping () -> Void) -> ContentLoadingErrorView {
        .init(
            title: AvatarLoadingError.title,
            description: description,
            buttonTitle: AvatarLoadingError.buttonTitle,
            buttonAction: buttonAction
        )
    }
}

enum AvatarLoadingError {
    static let title = NSLocalizedString(
        "AvatarPicker.Avatars.Loading.Error.title",
        value: "Unable to load avatars",
        comment: "The title of the error shown when avatars cannot be loaded."
    )
    static let description = NSLocalizedString(
        "AvatarPicker.Avatars.Loading.Error.description",
        value: "There was an issue loading your avatars. Please try again in a few minutes.",
        comment: "The description of the error shown when avatars cannot be loaded."
    )
    static let buttonTitle = NSLocalizedString(
        "AvatarPicker.Avatars.Loading.Error.buttonTitle",
        value: "Retry",
        comment: "The title of the retry button shown when avatars cannot be loaded."
    )
}
