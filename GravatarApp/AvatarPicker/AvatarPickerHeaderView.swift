import GravatarUI
import SwiftUI

struct AvatarPickerHeaderView: View {
    @Binding var profile: Profile

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
                        EllipsisButton(action: {})
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
        HeaderAvatarView(imageURL: imageURL, showLoading: true) {
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
        HeaderAvatarView(imageURL: imageURL, showLoading: false) {
            Color.clear
        }
        .scaledToFill()
        .frame(width: with, height: .headerHeight)
        .blur(radius: 10)
        .clipped()
        .opacity(0.8)
    }
}

#if DEBUG
#Preview {
    AvatarPickerHeaderView(profile: .constant(.testProfile))
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

// MARK: - Helpers

private struct HeaderAvatarView<Placeholder>: View where Placeholder: View {
    let imageURL: URL?
    let showLoading: Bool
    let placeholderView: () -> Placeholder

    var body: some View {
        AvatarView(
            url: imageURL,
            placeholderView: {
                placeholderView()
            },
            // TODO: Temporarely force refresh to try different avatars
            forceRefresh: .constant(true),
            loadingView: {
                showLoading ?
                    AnyView(ProgressView().progressViewStyle(.circular))
                    :
                    AnyView(EmptyView())
            },
            transaction:
            Transaction(animation: .smooth)
        )
    }
}
