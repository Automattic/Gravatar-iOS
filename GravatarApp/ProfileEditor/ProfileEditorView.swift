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
                    Spacer().frame(height: 80)
                }
            }.animation(.smooth(duration: 0.3), value: viewModel.hasUnsavedChanges)
        }
    }
}

struct SaveToolbar: View {
    @ObservedObject var viewModel: EditProfileViewModel

    var body: some View {
        HStack {
            if viewModel.isSaving {
                Text("Saving...").font(.headline)
                Spacer()
            } else {
                Text("Unsaved changes").font(.headline)
                Spacer()
                Button {

                } label: {
                    Text("Cancel")
                }
                .buttonStyle(ActionButtonStyle(style: .secondary))

                Button {
                    Task {
                        await viewModel.save()
                    }
                } label: {
                    Text("Save")
                }
                .environment(\.colorScheme, .light)
                .buttonStyle(ActionButtonStyle(style: .primary))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.DS.bluishColor)
        .transition(.move(edge: .bottom))
        .environment(\.colorScheme, .dark)
    }
}

struct ActionButtonStyle: ButtonStyle {
    enum Style {
        case primary
        case secondary
    }
    let style: Style

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(style == .primary ? Color.primary: Color(uiColor: .quaternaryLabel))
            .foregroundStyle(style == .primary ? Color(uiColor: .systemBackground) : Color.primary)
            .clipShape(.capsule)
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
