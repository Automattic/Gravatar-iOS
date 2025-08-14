import Gravatar
import SwiftUI

struct MainMenu: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var modalManager: ModalPresentationManager
    @State private var shareProfileURL: URL?
    let onMenuAppear: (() -> Void)?

    let profile: Profile
    let notificationCenter: NotificationCenter

    init(profile: Profile, notificationCenter: NotificationCenter = .default, onMenuAppeared: (() -> Void)? = nil) {
        self.profile = profile
        self.notificationCenter = notificationCenter
        self.onMenuAppear = onMenuAppeared
    }

    var body: some View {
        MenuButton {
            EllipsisButton {
                onMenuAppear?()
            }
        } content: {
            menuItems()
        }
        .sheet(item: $shareProfileURL) { url in
            ShareSheet(items: [url])
                .presentationDetents([.medium, .large])
        }
        .frame(width: 44, height: 44)
    }

    @MenuBuilder
    func menuItems() -> [MenuElement] {
        MenuSection {
            MenuItem(Localized.visitProfileTitle, systemImage: "safari") {
                guard let url = URL(string: profile.profileUrl) else { return }
                openURL(url)
            }
            MenuItem(Localized.shareTitle, systemImage: "square.and.arrow.up") {
                shareProfileURL = profile.profileURL
            }
            MenuItem("Gravatar.com", systemImage: "globe") {
                guard let url = URL(string: "https://gravatar.com") else { return }
                openURL(url)
            }
            MenuItem(Localized.aboutTitle, systemImage: "list.bullet.clipboard") {
                modalManager.present {
                    AboutView()
                }
            }
        }
        MenuSection {
            MenuItem(
                Localized.signOutTitle,
                systemImage: "iphone.and.arrow.forward.outward",
                attributes: .destructive
            ) {
                notificationCenter.post(name: .signOut, object: nil)
            }
        }
    }
}

private enum Localized {
    static let visitProfileTitle: String = NSLocalizedString(
        "MainMenu.Option.visitProfile",
        value: "Visit your profile",
        comment: "Title for the button to visit the user's profile"
    )
    static let shareTitle: String = NSLocalizedString(
        "MainMenu.Option.share",
        value: "Share profile",
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
    MainMenu(profile: .testProfile)
        // Make the menu show downwards
        .padding(.bottom, 200)
}
#endif
