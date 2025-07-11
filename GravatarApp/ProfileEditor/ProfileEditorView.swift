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
        AnimatedHeaderScrollView(animationBehavior: .interactive) { topSafeArea in
            ProfileEditorScrollableHeaderView(
                profile: viewModel.userSession.profile,
                topSafeArea: topSafeArea,
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
#endif
