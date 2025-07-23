import SwiftUI

struct PrivateInformationAlertView: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: .Global.verticalSectionSpacing) {
            VStack(alignment: .leading, spacing: .Global.verticalElementsSpacing) {
                Text(Localized.title)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(Localized.message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            VStack(spacing: .Global.verticalElementsSpacing) {
                Button {
                    onDismiss()
                } label: {
                    Text(Localized.dismissButton).frame(maxWidth: .infinity)
                }
                .buttonStyle(.actionButton())
                Button {} label: {
                    Text(Localized.moreInfoButton).frame(maxWidth: .infinity)
                }
                .buttonStyle(.actionButton(style: .secondary))
            }
        }
        .padding()
    }
}

private enum Localized {
    static let dismissButton = NSLocalizedString(
        "Share.PrivateInfoAlert.DismissButton.title",
        value: "Got it",
        comment: "Button title to dismiss the private information alert"
    )
    static let moreInfoButton = NSLocalizedString(
        "Share.PrivateInfoAlert.MoreInfoButton.title",
        value: "Learn more",
        comment: "Title of the button to show extra explanation about sharing private information"
    )
    static let title = NSLocalizedString(
        "Share.PrivateInfoAlert.title",
        value: "Private information",
        comment: "Title of the explaining alert about sharing private information"
    )
    static let message = NSLocalizedString(
        "Share.PrivateInfoAlert.message",
        value: "Your email and phone number are only shared using the QR code. This information is not saved to your Gravatar profile, and is not publicly available.",
        comment: "Message explanation about sharing private information"
    )
}

#Preview {
    ModalView {
        PrivateInformationAlertView(onDismiss: {})
    }
}
