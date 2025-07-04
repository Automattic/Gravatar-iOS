import GravatarUI
import SwiftUI

struct AvatarPickerHeaderView: View {
    @Binding var profile: Profile
    @Binding var forceRefresh: Bool

    let onActionPressed: () -> Void

    private var imageURL: URL? {
        AvatarURL(
            with: .hashID(profile.hash),
            options: .init(preferredSize: .points(.circlesSize))
        )?.url
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                backgroundImageView(with: geometry.size.width)

                overlayColor
                    .edgesIgnoringSafeArea(.all)

                ZStack {
                    HStack(alignment: .bottom) {
                        Spacer()
                        smallImageView()
                        Spacer()
                    }

                    HStack {
                        Spacer()
                        ellipsisMenu()
                    }
                }
                .padding(.horizontal, .hPadding)
                .padding(.bottom, .bottomPadding)
            }
            .frame(width: geometry.size.width, height: .headerHeight)
        }
        .frame(height: .headerHeight)
        .ignoresSafeArea()
    }

    private var overlayColor: Color {
        .black
            .opacity(0.2)
    }

    private func smallImageView() -> some View {
        HeaderAvatarView(imageURL: imageURL, showLoading: true, forceRefresh: $forceRefresh) {
            Image(systemName: "person.circle")
                .font(.system(size: .circlesSize, weight: .thin))
                .circleElementSize()
        }
        .shape(
            Circle(),
            borderColor: overlayColor,
            borderWidth: 1
        )
        .circleElementSize()
    }

    private func backgroundImageView(with: CGFloat) -> some View {
        HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
            Color.clear
        }
        .scaledToFill()
        .frame(width: with, height: .headerHeight)
        .blur(radius: 10)
        .clipped()
        .opacity(0.8)
    }

    private func ellipsisMenu() -> some View {
        Menu {
            Button(
                "Logout",
                systemImage: "iphone.and.arrow.forward.outward",
                role: .destructive
            ) {
                onActionPressed()
            }
        } label: {
            EllipsisButton(action: {})
        }
    }
}

#if DEBUG
#Preview {
    AvatarPickerHeaderView(
        profile: .constant(.testProfile),
        forceRefresh: .constant(false),
        onActionPressed: {}
    )
    Spacer()
}
#endif

// MARK: - Constants

extension CGFloat {
    fileprivate static let headerHeight: CGFloat = 110
    fileprivate static let circlesSize: CGFloat = 40
    fileprivate static let hPadding: CGFloat = 16
    fileprivate static let bottomPadding: CGFloat = 12
}

extension View {
    fileprivate func circleElementSize() -> some View {
        self.frame(width: .circlesSize, height: .circlesSize)
    }
}
