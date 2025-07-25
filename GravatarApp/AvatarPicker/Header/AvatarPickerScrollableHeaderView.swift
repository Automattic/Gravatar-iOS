import SwiftUI

struct AvatarPickerScrollableHeaderView: View {
    let topPadding: CGFloat
    let imageURL: URL?
    @Binding var forceRefresh: Bool

    var body: some View {
        BouncyImageBackgroundHeaderView(
            topPadding: topPadding,
            imageURL: imageURL,
            forceRefresh: $forceRefresh
        ) {
            ZStack(alignment: .bottom) {
                bigAvatar()

                smallAvatar()
                    .offset(x: 60)
            }
        }
    }

    func bigAvatar() -> some View {
        avatar
            .frame(width: 105, height: 105)
            .avatarSytle(Circle())
    }

    func smallAvatar() -> some View {
        avatar
            .frame(width: 49, height: 49)
            .avatarSytle(RoundedRectangle(cornerRadius: 7))
    }

    var avatar: some View {
        HeaderAvatarView(
            imageURL: imageURL,
            showLoading: true,
            forceRefresh: $forceRefresh,
            placeholderColor: .DS.avatarPlaceholderColor,
            animation: .smooth
        )
    }
}

#Preview {
    let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")
    GeometryReader { geo in
        VStack {
            AvatarPickerScrollableHeaderView(
                topPadding: geo.safeAreaInsets.top,
                imageURL: imageURL,
                forceRefresh: .constant(false)
            )
            Spacer()
        }.ignoresSafeArea()
    }
}
