import SwiftUI
import Gravatar

struct MainMenuOptions: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var modalManager: ModalPresentationManager

    let profile: Profile
    let notificationCenter: NotificationCenter

    init(profile: Profile, notificationCenter: NotificationCenter = .default) {
        self.profile = profile
        self.notificationCenter = notificationCenter
    }

    var body: some View {
        Button(Localized.visitProfileTitle, systemImage: "safari") {
            guard let url = URL(string: profile.profileUrl) else { return }
            openURL(url)
        }
        ShareLink(item: profile.profileUrl) {
            HStack {
                Text(Localized.shareTitle)
                Image(systemName: "square.and.arrow.up")
            }
        }
        Button("Gravatar.com", systemImage: "globe") {
            guard let url = URL(string: "https://gravatar.com") else { return }
            openURL(url)
        }
        Button(Localized.aboutTitle, systemImage: "list.bullet.clipboard") {
            modalManager.present {
                AboutView()
            }
        }
        Divider()
        Button(
            Localized.signOutTitle,
            systemImage: "iphone.and.arrow.forward.outward",
            role: .destructive
        ) {
            notificationCenter.post(name: .signOut, object: nil)
        }
    }
}

struct AboutView: View {
    @EnvironmentObject var modalManager: ModalPresentationManager

    var body: some View {
        VStack(alignment: .leading) {
            title("About Gravatar")
            Text("v\(getAppVersion())")
                .foregroundStyle(.secondary)
            title("Get help")
            link("support.gravatar.com", url: "https://support.gravatar.com")
            link("support@gravatar.com", url: "mailto:support@gravatar.com")
            title("Legal")
            link("Terms of Service", url: "https://gravatar.com")
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

#Preview {
    AboutView()
}

private enum Localized {
    static let visitProfileTitle: String = NSLocalizedString(
        "MainMenu.Option.visitProfile",
        value: "Visit your profile",
        comment: "Title for the button to visit the user's profile"
    )
    static let shareTitle: String = NSLocalizedString(
        "MainMenu.Option.share",
        value: "Share",
        comment: "Title for the button to share the user's profile"
    )
    static let aboutTitle: String = NSLocalizedString(
        "MainMenu.Option.about",
        value: "About this app",
        comment: "Title for the button to show 'about this app' section"
    )
    static let signOutTitle: String = NSLocalizedString(
        "MainMenu.Option.signOut",
        value: "Sign out",
        comment: "Title for the button to sign out"
    )
}

#if DEBUG
#Preview {
    Menu {
        MainMenuOptions(profile: .testProfile)
    } label: {
        EllipsisButton {}
    }
    // Make the menu show downwards
    .padding(.bottom, 200)
}
#endif
