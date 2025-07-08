import SwiftUI

struct AvatarPickerStickyHeaderView: View {
    let opacity: CGFloat
    let safeAreaInsets: EdgeInsets
    let imageURL: URL?
    @Binding var forceRefresh: Bool

    var body: some View {
        BouncyImageBackgroundHeaderView(topSafeArea: safeAreaInsets.top, imageURL: imageURL, forceRefresh: $forceRefresh) {
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
        HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
            EmptyView()
        }
        .frame(width: 44, height: 44)
        .shape(Circle(), borderColor: .black.opacity(0.2), borderWidth: 2)
        .shadow(radius: 2, x: 0, y: 3)
    }

    func smallAvatar() -> some View {
        HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
            EmptyView()
        }
        .frame(width: 33, height: 33)
        .shape(RoundedRectangle(cornerRadius: 7), borderColor: .black.opacity(0.2), borderWidth: 2)
        .shadow(radius: 2, x: 0, y: 3)
    }
}

#Preview {
    let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")
    VStack {
        AvatarPickerStickyHeaderView(
            opacity: 1,
            safeAreaInsets: EdgeInsets(),
            imageURL: imageURL,
            forceRefresh: .constant(false)
        )
        Spacer()
    }
}
