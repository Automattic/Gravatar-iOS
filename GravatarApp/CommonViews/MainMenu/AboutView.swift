import SwiftUI
import Analytics

struct AboutView: View {
    @EnvironmentObject var modalManager: ModalPresentationManager
    @Environment(\.analytics) private var analytics
    @State private var inAppURL: URL?
    @Environment(\.openURL) private var openURL

    @State private var presentAccountDeletionWarning: Bool = false

    private let textColor = Color.primary.opacity(0.6)
    private let notificationCenter: NotificationCenter

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .Global.verticalSectionSpacing) {
            VStack(alignment: .leading) {
                title(Localized.aboutTitle)
                label("v\(getAppVersion())")
            }
            VStack(alignment: .leading) {
                title(Localized.getHelpTitle)
                link(
                    "support.gravatar.com",
                    url: "https://support.gravatar.com",
                    event: AboutModalEvents.supportLinkTapped
                )
                link(
                    "support@gravatar.com",
                    url: "mailto:support@gravatar.com",
                    event: AboutModalEvents.supportEmailTapped
                )
            }
            VStack(alignment: .leading) {
                title(Localized.legalTitle)
                inAppSafariLink(
                    Localized.termsOfServiceText,
                    url: "https://automattic.com/tos/",
                    tracking: AboutModalEvents.tosTapped
                )
                inAppSafariLink(
                    Localized.privacyPolicyText,
                    url: "https://automattic.com/privacy/",
                    tracking: AboutModalEvents.privacyPolicyTapped
                )
            }
            VStack(alignment: .leading) {
                title(Localized.deleteAccountTitle)
                label(Localized.deleteAccountMessage)
                deleteAccountButton
            }

            Button {
                modalManager.dismiss()
            } label: {
                Text(Localized.closeButtonTitle)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.actionButton())
            .padding(.top, .DS.Padding.single)
        }
        .padding()
        .presentSafariView(url: $inAppURL)
        .onAppear {
            analytics.track(AboutModalEvents.screenView)
        }
        .onDisappear {
            analytics.track(AboutModalEvents.screenLeave)
        }
    }

    private func title(_ text: String) -> some View {
        Text(text)
            .font(.title3)
            .fontWeight(.semibold)
            .padding(.bottom, .DS.Padding.half)
    }

    private func link(_ text: String, url: String, event: AnalyticsEvent) -> some View {
        Button {
            analytics.track(event)
            openURL(URL(string: url)!)
        } label: {
            Text(text)
        }
        .foregroundStyle(textColor)
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(textColor)
    }

    private var deleteAccountButton: some View {
        Button {
            analytics.track(AboutModalEvents.deleteAccountTapped)
            presentAccountDeletionWarning = true
        } label: {
            Text(Localized.deleteAccountTitle)
                .foregroundColor(.red)
                .padding(.top, .DS.Padding.half)
        }
        .confirmationDialog(Localized.deleteAccountWarningTitle, isPresented: $presentAccountDeletionWarning, titleVisibility: .visible) {
            Button(Localized.deleteAccountTitle, role: .destructive) {
                analytics.track(AboutModalEvents.deleteAccountWarningAccepted)
                notificationCenter.post(name: .deleteAccount, object: nil)
            }
            Button(Localized.cancelTitle, role: .cancel) {
                analytics.track(AboutModalEvents.deleteAccountWarningCancelled)
            }
        } message: {
            Text(Localized.deleteAccountWarningMessage)
        }
    }

    private func inAppSafariLink(_ text: String, url: String, tracking event: any AnalyticsEvent) -> some View {
        Button {
            analytics.track(event)
            inAppURL = URL(string: url)
        } label: {
            Text(text)
                .foregroundStyle(textColor)
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

    static let deleteAccountTitle = NSLocalizedString(
        "AboutModal.accountDeletion.title",
        value: "Delete account",
        comment: "Title for the 'Delete account' section in the 'About Gravatar' view"
    )

    static let cancelTitle = NSLocalizedString(
        "AboutModal.accountDeletion.cancel",
        value: "Cancel",
        comment: "Title for the 'Cancel' button when deleting an account in the 'About Gravatar' view"
    )

    static let deleteAccountMessage = NSLocalizedString(
        "AboutModal.accountDeletion.message",
        value: "No longer using Gravatar? Delete your account here.",
        comment: "Warning message for the 'Delete account' section in the 'About Gravatar' view"
    )

    static let deleteAccountWarningTitle = NSLocalizedString(
        "AboutModal.accountDeletion.warning.message",
        value: "Deleting your Gravatar account will immediately prevent all access to your profile",
        comment: "Detailed Title warning for the 'Delete account' action in the 'About Gravatar' view"
    )

    static let deleteAccountWarningMessage = NSLocalizedString(
        "AboutModal.accountDeletion.warning.message",
        value: "Your data will be permanently deleted after 30 days. During this period, you can still restore your profile by logging in at gravatar.com using your browser. After 30 days, it will no longer be recoverable.",
        comment: "Detailed warning message for the 'Delete account' section in the 'About Gravatar' view"
    )
}

#Preview {
    ModalView {
        AboutView()
            .environmentObject(ModalPresentationManager())
    }
}
