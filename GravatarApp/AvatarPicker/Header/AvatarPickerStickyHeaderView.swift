import SwiftUI

struct AvatarPickerStickyHeaderView: View {
    let opacity: CGFloat
    let safeAreaInsets: EdgeInsets
    let imageURL: URL?
    @Binding var forceRefresh: Bool

    var body: some View {
        BouncyImageBackgroundHeaderView(topPadding: safeAreaInsets.top, imageURL: imageURL, forceRefresh: $forceRefresh) {
            HStack(alignment: .center) {
                bigAvatar()

                smallAvatar()

                Spacer()
            }
            .padding(.horizontal, safeAreaInsets.leading + 16)
        }
        .opacity(opacity)
    }

    func bigAvatar() -> some View {
        avatar
            .frame(width: 44, height: 44)
            .avatarSytle(Circle())
    }

    func smallAvatar() -> some View {
        avatar
            .frame(width: 33, height: 33)
            .avatarSytle(RoundedRectangle(cornerRadius: 7))
    }

    var avatar: some View {
        HeaderAvatarView(
            imageURL: imageURL,
            showLoading: false,
            forceRefresh: $forceRefresh,
            placeholderColor: .DS.avatarPlaceholderColor
        )
    }
}

#Preview {
    let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")
    GeometryReader { geo in
        VStack {
            AvatarPickerStickyHeaderView(
                opacity: 1,
                safeAreaInsets: geo.safeAreaInsets,
                imageURL: imageURL,
                forceRefresh: .constant(false)
            )
            Spacer()
        }.ignoresSafeArea()
    }
}
