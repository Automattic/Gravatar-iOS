import Gravatar
import SwiftUI

struct ProfileEditorStickyHeaderView: View {
    let profile: Profile

    let opacity: CGFloat
    let safeAreaInsets: EdgeInsets
    let imageURL: URL?
    @Binding var forceRefresh: Bool

    var body: some View {
        BouncyImageBackgroundHeaderView(
            topPadding: safeAreaInsets.top,
            imageURL: imageURL,
            forceRefresh: $forceRefresh
        ) {
            HStack(alignment: .center) {
                avatar()

                profileInfo()

                Spacer()
            }
            .padding(.horizontal, safeAreaInsets.leading + .Global.contentHorizontalPadding)
            .readableContentWidth()

        }
        .opacity(opacity)
    }

    func avatar() -> some View {
        HeaderAvatarView(
            imageURL: imageURL,
            showLoading: true,
            forceRefresh: $forceRefresh,
            placeholderColor: .DS.avatarPlaceholderColor
        )
        .frame(width: 44, height: 44)
        .avatarSytle(Circle())
    }

    func profileInfo() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(profile.displayName).font(.title3).fontWeight(.semibold)
            if let profession = profile.professionFullDescription, !profession.isEmpty {
                Text(profession).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .lineLimit(1)
        .padding(.trailing, 44) // Avoid main menu button.
        .environment(\.colorScheme, .dark)
    }
}

#if DEBUG
#Preview {
    let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")
    GeometryReader { geo in
        VStack {
            ProfileEditorStickyHeaderView(
                profile: .testProfile,
                opacity: 1,
                safeAreaInsets: geo.safeAreaInsets,
                imageURL: imageURL,
                forceRefresh: .constant(false)
            )
            Spacer()
        }.ignoresSafeArea()
    }
}
#endif
