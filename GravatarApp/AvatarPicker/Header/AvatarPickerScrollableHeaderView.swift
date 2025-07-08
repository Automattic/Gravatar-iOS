import SwiftUI

struct AvatarPickerScrollableHeaderView: View {
    let topSafeArea: CGFloat
    let imageURL: URL?
    @Binding var forceRefresh: Bool

    var body: some View {
        BouncyImageBackgroundHeaderView(topSafeArea: topSafeArea, imageURL: imageURL, forceRefresh: $forceRefresh) {
            ZStack(alignment: .bottom) {
                HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
                    EmptyView()
                }
                .frame(width: 105, height: 105)
                .shape(Circle(), borderColor: .black.opacity(0.2), borderWidth: 2)
                .shadow(radius: 2, x: 0, y: 3)
                HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
                    EmptyView()
                }
                .frame(width: 49, height: 49)
                .shape(RoundedRectangle(cornerRadius: 7), borderColor: .black.opacity(0.2), borderWidth: 2)
                .offset(x: 60)
                .shadow(radius: 2, x: 0, y: 3)
            }
        }
    }
}

#Preview {
    let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")
    VStack {
        AvatarPickerScrollableHeaderView(
            topSafeArea: 0,
            imageURL: imageURL,
            forceRefresh: .constant(false)
        )
        Spacer()
    }
}
