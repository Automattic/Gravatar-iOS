import Gravatar
import SwiftUI

struct ProfileEditorScrollableHeaderView: View {
    let profile: Profile
    let topPadding: CGFloat
    let imageURL: URL?
    @Binding var forceRefresh: Bool

    @Environment(\.openURL) var openURL

    var body: some View {
        BouncyImageBackgroundHeaderView(
            topPadding: topPadding,
            imageURL: imageURL,
            forceRefresh: $forceRefresh
        ) {
            VStack(spacing: 16) {
                avatar()

                Group {
                    profileInfo()
                    profileURLButton()
                }
                .readableContentWidth()
                .multilineTextAlignment(.center)
                .environment(\.colorScheme, .dark)
            }
            .padding(.horizontal, .Global.contentHorizontalPadding)
        }
    }

    func avatar() -> some View {
        HeaderAvatarView(
            imageURL: imageURL,
            showLoading: true,
            forceRefresh: $forceRefresh,
            placeholderColor: .DS.avatarPlaceholderColor
        )
        .frame(width: 105, height: 105)
        .avatarSytle(Circle())
    }

    func profileInfo() -> some View {
        VStack(spacing: 0) {
            Text(profile.displayName).font(.title3).fontWeight(.semibold)
            if let profession = profile.professionFullDescription {
                Text(profession).font(.subheadline).opacity(0.8)
            }
            if !profile.location.isEmpty {
                Text(profile.location).font(.subheadline).opacity(0.8)
            }
        }
    }

    func profileURLButton() -> some View {
        Button {
            guard let url = URL(string: profile.profileUrl) else { return }
            openURL(url)
        } label: {
            Label {
                Text(profile.profileUrl.replacingOccurrences(of: "https://", with: ""))
                    .font(.subheadline)
            } icon: {
                Image(systemName: "safari")
                    .font(.subheadline)
            }
            .foregroundStyle(Color.primary)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.black)
            .clipShape(Capsule())
        }
    }
}

#if DEBUG
#Preview {
    let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")
    GeometryReader { geo in
        VStack {
            ProfileEditorScrollableHeaderView(
                profile: .testProfile,
                topPadding: geo.safeAreaInsets.top,
                imageURL: imageURL,
                forceRefresh: .constant(false)
            )
            Spacer()
        }.ignoresSafeArea()
    }
}
#endif
