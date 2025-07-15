import GravatarUI
import SwiftUI

struct ProfileEditorView: View {
    @State private var forceRefresh: Bool = false

    @ObservedObject var viewModel: EditProfileViewModel

    var headerAvatarURL: URL? {
        AvatarURL(
            with: .hashID(viewModel.userSession.profile.hash),
            options: .init(preferredSize: .pixels(256))
        )?.url
    }

    var body: some View {
        AnimatedHeaderScrollView(animationBehavior: .interactive) { topPadding in
            ProfileEditorScrollableHeaderView(
                profile: viewModel.userSession.profile,
                topPadding: topPadding,
                imageURL: headerAvatarURL,
                forceRefresh: $forceRefresh
            )
        } stickyHeader: { opacity, safeArea in
            ProfileEditorStickyHeaderView(
                profile: viewModel.userSession.profile,
                opacity: opacity,
                safeAreaInsets: safeArea,
                imageURL: headerAvatarURL,
                forceRefresh: $forceRefresh
            )
        } content: {
            ProfileEditContentView(viewModel: viewModel)
        } buttonMenuItems: {
            Button {} label: {
                Button(
                    "Logout (not implemented yet)",
                    systemImage: "iphone.and.arrow.forward.outward",
                    role: .destructive
                ) {}
            }
        } onRefresh: {
            await viewModel.fetchProfile()
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: nil) {
            Group {
                if viewModel.hasUnsavedChanges {
                    SaveToolbar(viewModel: viewModel)
                } else {
                    // Keep the save area of the same height of the toolbar
                    // It will grow acordingly with different font sizes
                    Button {} label: { Text("hidden") }
                        .buttonStyle(.actionButton(style: .primary))
                        .opacity(0)
                        .padding()
                }
            }
            .animation(.smooth(duration: 0.3), value: viewModel.hasUnsavedChanges)
        }
    }
}

#if DEBUG
#Preview {
    ProfileEditorView(
        viewModel: .init(
            userSession: UserSession(profile: .testProfile, accessToken: "", context: .testContext)
        )
    )
}

#Preview("With TabBar") {
    TabView {
        ProfileEditorView(
            viewModel: .init(
                userSession: UserSession(profile: .testProfile, accessToken: "", context: .testContext)
            )
        )
        .tabItem {
            Label("Profile", systemImage: "brain.filled.head.profile")
        }
    }
}
#endif
