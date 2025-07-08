import Gravatar
import SwiftUI

struct ProfileEditorStickyHeaderView: View {
    let profile: Profile

    let opacity: CGFloat
    let safeAreaInsets: EdgeInsets
    let imageURL: URL?
    @Binding var forceRefresh: Bool

    var profession: String? {
        [profile.jobTitle, profile.company].filter { !$0.isEmpty }.joined(separator: ", ")
    }

    var body: some View {
        BouncyImageBackgroundHeaderView(topSafeArea: safeAreaInsets.top, imageURL: imageURL, forceRefresh: $forceRefresh) {
            HStack(alignment: .top) {
                HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
                    EmptyView()
                }
                .frame(width: 44, height: 44)
                .shape(Circle(), borderColor: .black.opacity(0.2), borderWidth: 2)
                .shadow(radius: 2, x: 0, y: 3)

                VStack(alignment: .leading, spacing: 0) {
                    Text(profile.displayName).font(.title3).fontWeight(.semibold)
                    if let profession {
                        Text(profession).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, safeAreaInsets.leading + 16)
        }
        .opacity(opacity)
    }
}

#Preview {
    let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")
    VStack {
        ProfileEditorStickyHeaderView(
            profile: .testProfile,
            opacity: 1,
            safeAreaInsets: EdgeInsets(),
            imageURL: imageURL,
            forceRefresh: .constant(false)
        )
        Spacer()
    }
}
