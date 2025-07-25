import SwiftUI

struct AboutView: View {
    @EnvironmentObject var modalManager: ModalPresentationManager
    @State private var inAppURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: .Global.verticalSectionSpacing) {
            VStack(alignment: .leading) {
                title(Localized.aboutTitle)
                Text("v\(getAppVersion())")
                    .foregroundStyle(Color.primary.opacity(0.6))
            }
            VStack(alignment: .leading) {
                title(Localized.getHelpTitle)
                link("support.gravatar.com", url: "https://support.gravatar.com")
                link("support@gravatar.com", url: "mailto:support@gravatar.com")
            }
            VStack(alignment: .leading) {
                title(Localized.legalTitle)
                inAppSafariLink(Localized.termsOfServiceText, url: "https://automattic.com/tos/")
                inAppSafariLink(Localized.privacyPolicyText, url: "https://automattic.com/privacy/")
            }

            Button {
                modalManager.dismiss()
            } label: {
                Text(Localized.closeButtonTitle)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.actionButton())
        }
        .padding()
        .presentSafariView(url: $inAppURL)
    }

    private func title(_ text: String) -> some View {
        Text(text)
            .font(.title3)
            .fontWeight(.semibold)
            .padding(.bottom, .DS.Padding.half)
    }

    private func link(_ text: String, url: String) -> some View {
        Link(text, destination: URL(string: url)!)
            .foregroundStyle(Color.primary.opacity(0.6))
    }

    private func inAppSafariLink(_ text: String, url: String) -> some View {
        Button {
            inAppURL = URL(string: url)
        } label: {
            Text(text)
                .foregroundStyle(Color.primary.opacity(0.6))
        }
    }

    func getAppVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return "?"
    }
}

private enum Localized {
    static let aboutTitle = NSLocalizedString(
        "AboutModal.title",
        value: "About Gravatar",
        comment: "Title for the 'About Gravatar' view"
    )

    static let getHelpTitle = NSLocalizedString(
        "AboutModal.getHelpTitle",
        value: "Get help",
        comment: "Title for the 'Get help' section in the 'About Gravatar' view"
    )

    static let legalTitle = NSLocalizedString(
        "AboutModal.legalTitle",
        value: "Legal",
        comment: "Title for the 'Legal' section in the 'About Gravatar' view"
    )

    static let termsOfServiceText = NSLocalizedString(
        "AboutModal.termsOfServiceText",
        value: "Terms of Service",
        comment: "Link text for the 'Terms of Service' in the 'About Gravatar' view"
    )

    static let privacyPolicyText = NSLocalizedString(
        "AboutModal.privacyPolicyText",
        value: "Privacy Policy",
        comment: "Link text for the 'Privacy Policy' in the 'About Gravatar' view"
    )

    static let closeButtonTitle = NSLocalizedString(
        "AboutModal.CloseButton.title",
        value: "Done",
        comment: "Text for the 'Done' button in the 'About Gravatar' view"
    )
}

#Preview {
    ModalView {
        AboutView()
            .environmentObject(ModalPresentationManager())
    }
}
