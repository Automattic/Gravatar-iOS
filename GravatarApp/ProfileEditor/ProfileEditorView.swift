import GravatarUI
import SwiftUI

struct ProfileEditorView: View {
    @ObservedObject var viewModel: EditProfileViewModel
    @Binding var forceRefreshAvatar: Bool
    @Environment(\.analytics) var analytics

    var headerAvatarURL: URL? {
        AvatarURL.preferredURL(for: viewModel.userSession.profile.hash)
    }

    var body: some View {
        AnimatedHeaderScrollView(animationBehavior: .interactive) { topPadding in
            ProfileEditorScrollableHeaderView(
                profile: viewModel.userSession.profile,
                topPadding: topPadding,
                imageURL: headerAvatarURL,
                forceRefresh: $forceRefreshAvatar,
                onProfileButtonTapped: {
                    analytics.track(ProfileEditorEvents.profileHeaderLinkTapped)
                }
            )
        } stickyHeader: { opacity, safeArea in
            ProfileEditorStickyHeaderView(
                profile: viewModel.userSession.profile,
                opacity: opacity,
                safeAreaInsets: safeArea,
                imageURL: headerAvatarURL,
                forceRefresh: $forceRefreshAvatar
            )
        } content: {
            ProfileEditContentView(viewModel: viewModel)
                .readableContentWidth()
        } mainMenuButton: {
            MainMenu(profile: viewModel.userSession.profile) {
                analytics.track(ProfileEditorEvents.mainMenuTapped)
            }
        } onRefresh: {
            await viewModel.fetchProfile()
            forceRefreshAvatar = true
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: nil) {
            Group {
                if viewModel.hasUnsavedChanges {
                    SaveToolbar(viewModel: viewModel) {
                        analytics.track(ProfileEditorEvents.profileSaveChangesTapped)
                    } onCancel: {
                        analytics.track(ProfileEditorEvents.profileCancelChangesTapped)
                    }
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
        .onAppear {
            analytics.track(ProfileEditorEvents.screenView)
        }
        .onDisappear {
            analytics.track(ProfileEditorEvents.screenLeave)
        }
    }
}

#if DEBUG
#Preview {
    ProfileEditorView(
        viewModel: .init(
            userSession: UserSession(profile: .testProfile, accessToken: "", context: .testContext)
        ), forceRefreshAvatar: .constant(false)
    )
}

#Preview("With TabBar") {
    TabView {
        ProfileEditorView(
            viewModel: .init(
                userSession: UserSession(profile: .testProfile, accessToken: "", context: .testContext)
            ), forceRefreshAvatar: .constant(false)
        )
        .tabItem {
            Label("Profile", systemImage: "brain.filled.head.profile")
        }
    }
}
#endif
