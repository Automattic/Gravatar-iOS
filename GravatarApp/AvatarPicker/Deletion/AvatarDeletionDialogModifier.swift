import SwiftUI

struct AvatarDeletionDialogModifier: ViewModifier {
    @Binding var avatar: AvatarImageModel?
    let deleteAction: (AvatarImageModel) -> Void
    let cancelAction: (AvatarImageModel) -> Void

    func body(content: Content) -> some View {
        content.confirmationDialog(
            "",
            isPresented: Binding(
                get: { avatar != nil },
                set: { if !$0 { avatar = nil } }
            ),
            presenting: avatar
        ) { avatar in
            Button(Localized.deleteButtonTitle, role: .destructive) {
                deleteAction(avatar)
            }
            Button(Localized.cancelButtonTitle, role: .cancel) {
                cancelAction(avatar)
            }
        } message: { _ in
            Text(Localized.confirmationTitle)
        }
    }
}

extension View {
    func avatarDeletionDialog(
        avatar: Binding<AvatarImageModel?>,
        deleteAction: @escaping (AvatarImageModel) -> Void,
        cancelAction: @escaping (AvatarImageModel) -> Void
    ) -> some View {
        self.modifier(AvatarDeletionDialogModifier(
            avatar: avatar,
            deleteAction: deleteAction,
            cancelAction: cancelAction
        ))
    }
}

private enum Localized {
    fileprivate static let confirmationTitle = NSLocalizedString(
        "AvatarPicker.Deletion.Confirmation.title",
        value: "Are you sure you want to delete this image?",
        comment: "Title of the confirmation dialog to delete an avatar"
    )
    fileprivate static let deleteButtonTitle = NSLocalizedString(
        "AvatarPicker.Deletion.Confirmation.ctaButtonTitle",
        value: "Delete",
        comment: "The title button which confirms the avatar deletion."
    )
    fileprivate static let cancelButtonTitle = NSLocalizedString(
        "AvatarPicker.Deletion.Cancel.buttonTitle",
        value: "Cancel",
        comment: "The title button which cancels the avatar deletion."
    )
}
