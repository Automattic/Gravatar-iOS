import SwiftUI

struct AvatarUploadErrorDialogModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var uploadError: AvatarUploadErrorInfo?
    let action: (AvatarUploadErrorAction) -> Void

    func body(content: Content) -> some View {
        content.confirmationDialog(
            Localized.uploadErrorTitle,
            isPresented: $isPresented,
            titleVisibility: .visible,
            presenting: uploadError
        ) { error in
            Button(role: .destructive) {
                action(.delete(error.avatarLocalID))
            } label: {
                Label(Localized.removeButtonTitle, systemImage: "trash")
            }
            if error.supportsRetry {
                Button {
                    action(.retry(error.avatarLocalID))
                } label: {
                    Label(Localized.retryButtonTitle, systemImage: "arrow.clockwise")
                }
            }
            Button(Localized.dismissButtonTitle, role: .cancel) {}
        } message: { error in
            Text(error.errorMessage)
        }
    }
}

extension View {
    func avatarUploadErrorDialog(
        isPresented: Binding<Bool>,
        uploadError: Binding<AvatarUploadErrorInfo?>,
        action: @escaping (AvatarUploadErrorAction) -> Void
    ) -> some View {
        self.modifier(AvatarUploadErrorDialogModifier(
            isPresented: isPresented,
            uploadError: uploadError,
            action: action
        ))
    }
}

private enum Localized {
    static let uploadErrorTitle = NSLocalizedString(
        "AvatarPicker.Upload.Error.title",
        value: "Upload has failed",
        comment: "The title of the upload error dialog."
    )
    static let removeButtonTitle = NSLocalizedString(
        "AvatarPicker.Upload.Error.Remove.title",
        value: "Remove",
        comment: "The title of the remove button on the upload error dialog."
    )
    static let retryButtonTitle = NSLocalizedString(
        "AvatarPicker.Upload.Error.Retry.title",
        value: "Retry",
        comment: "The title of the retry button on the upload error dialog."
    )
    static let dismissButtonTitle = NSLocalizedString(
        "AvatarPicker.Dismiss.title",
        value: "Dismiss",
        comment: "The title of the dismiss button on a confirmation dialog."
    )
}
