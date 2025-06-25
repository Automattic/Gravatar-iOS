import Gravatar
import SwiftUI

struct RootTabView: View {
    let profile: Profile
    let onLogout: () -> Void

    var body: some View {
        TabView {
            // MARK: - First tab

            GravatarTab(profile: profile, onLogout: onLogout)

            // MARK: - Second tab

            ProfileTab(profile: profile, onLogout: onLogout)

            // MARK: - Third tab

            ShareTab()
        }
    }
}

struct GravatarTab: View {
    let profile: Profile
    let onLogout: () -> Void

    var body: some View {
        BackgroundColorView(color: .secondarySystemBackground) {
            ContentView(profile: profile, onLogout: onLogout)
        }
        .tabItem {
            Label("Gravatar", image: "gravatar-logo")
        }
    }
}

struct ProfileTab: View {
    let profile: Profile
    let onLogout: () -> Void

    var body: some View {
        BackgroundColorView(color: .secondarySystemBackground) {
            Self.content(with: profile, onLogout: onLogout)
        }
        .tabItem {
            Label("Profile", systemImage: "brain.filled.head.profile")
        }
    }

    static func content(with profile: Profile, onLogout: @escaping () -> Void) -> CollapsableHeaderScrollView<TestProfileContent> {
        let profileView = TestProfileContent(profile: profile, onLogout: onLogout)
        return CollapsableHeaderScrollView<TestProfileContent>(
            headerContentView: ProfileHeaderContentView(),
            scrollableContent: .swiftUI(profileView),
            headerMaxHeight: 250,
            headerMinHeight: 100
        )
    }
}

struct ShareTab: View {
    var body: some View {
        NavigationStack {
            BackgroundColorView(color: .secondarySystemBackground) {
                Text("Share!")
            }
            .navigationTitle("Share")
            .navigationBarItems(
                trailing: Button("Share", systemImage: "square.and.arrow.up", action: {})
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .tabItem {
            Label("Share", systemImage: "qrcode")
        }
    }
}

struct BackgroundColorView<Content>: View where Content: View {
    let color: UIColor
    let content: () -> Content

    var body: some View {
        ZStack {
            Color(uiColor: color)
                .ignoresSafeArea()
            content()
        }
    }
}

#if DEBUG // Needed when we use `Profile.testProfile on Previews`
#Preview {
    RootTabView(profile: .testProfile, onLogout: {})
}
#endif
