import SwiftUI

struct AboutView: View {
    @EnvironmentObject var modalManager: ModalPresentationManager

    var body: some View {
        VStack(alignment: .leading) {
            title(Localized.aboutTitle)
            Text("v\(getAppVersion())")
                .foregroundStyle(.secondary)
            title(Localized.getHelpTitle)
            link("support.gravatar.com", url: "https://support.gravatar.com")
            link("support@gravatar.com", url: "mailto:support@gravatar.com")
            title(Localized.legalTitle)

            // TODO: Use real links. Maybe open in-app webview.
            link(Localized.termsOfServiceText, url: "https://gravatar.com")
            link("Privacy Policy", url: "https://gravatar.com")

            Button {
                modalManager.dismiss()
            } label: { Text("Done").frame(maxWidth: .infinity) }
                .buttonStyle(.actionButton(style: .secondary))
                .padding(.top, 16)
        }
        .padding()
    }

    private func title(_ text: String) -> some View {
        Text(text)
            .font(.title3)
            .fontWeight(.semibold)
            .padding(.top, 16)
    }

    private func link(_ text: String, url: String) -> some View {
        Link(text, destination: URL(string: url)!)
            .foregroundStyle(.secondary)
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
}

#Preview {
    AboutView()
        .environmentObject(ModalPresentationManager())
}
