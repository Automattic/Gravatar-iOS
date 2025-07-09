import GravatarUI
import SwiftUI

struct BouncyImageBackgroundHeaderView<Content>: View where Content: View {
    let topSafeArea: CGFloat
    let imageURL: URL?
    @Binding var forceRefresh: Bool

    let content: () -> Content

    @State private var contentHeight: CGFloat = 0

    private var viewHeight: CGFloat {
        contentHeight + topSafeArea
    }

    var body: some View {
        GeometryReader { geo in
            let offset = geo.frame(in: .global).minY
            let isBouncing = (offset > 0)

            HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
                EmptyView()
            }
            .scaledToFill()
            .frame(width: geo.size.width, height: isBouncing ? viewHeight + offset : viewHeight)
            .clipped()
            .blur(radius: 40, opaque: true)
            .offset(y: isBouncing ? -offset : 0)
            .overlay(content: {
                Color.black.opacity(0.2)
                    .frame(height: isBouncing ? viewHeight + offset : viewHeight)
                    .offset(y: isBouncing ? -offset : 0)
            })
            .overlay {
                VStack {
                    Spacer()
                    content()
                        .if(topSafeArea == 0, transform: { view in
                            view.padding(.top)
                        })
                        .padding(.bottom)
                        .contentHeightReader($contentHeight)
                }
                .frame(height: isBouncing ? viewHeight + offset : viewHeight)
                .offset(y: isBouncing ? -offset : 0)
            }
        }
        .environment(\.colorScheme, .dark)
        .frame(height: viewHeight)
    }
}

#Preview {
    let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")

    ScrollView {
        BouncyImageBackgroundHeaderView(
            topSafeArea: 0,
            imageURL: imageURL,
            forceRefresh: .constant(false)
        ) {
            VStack {
                Text("Hello world")
                Text("Drag me down!")
            }
        }
    }
}
