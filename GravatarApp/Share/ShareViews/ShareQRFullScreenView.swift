import SwiftUI

struct ShareQRFullScreenView<QRImage: View>: View {
    @Binding var presentFullScreen: Bool
    let topPadding: CGFloat
    let imageURL: URL?
    @Binding var forceRefresh: Bool
    let windowWidth: CGFloat

    @ViewBuilder
    let qrImage: () -> QRImage

    @State private var originalScreenBrightness: CGFloat = 0

    var fullScreenQrWidth: CGFloat {
        let padding = CGFloat.Global.contentHorizontalPadding
        return min(
            windowWidth - padding * 2,
            500
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            closeButton
            Spacer()
            centralContent
            Spacer()
            // Balance space to keep the qr code at the center
            Image(systemName: "xmark")
                .opacity(0)
            Spacer()
        }
        .background {
            HeaderAvatarView(
                imageURL: imageURL,
                showLoading: false,
                forceRefresh: $forceRefresh,
                placeholderView: { EmptyView() }
            )
            .frame(maxHeight: .infinity)
            .darkBlurImageStyle(width: windowWidth)
        }
        .environment(\.colorScheme, .dark)
        .onAppear {
            originalScreenBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = 1
        }
        .onDisappear {
            UIScreen.main.brightness = originalScreenBrightness
        }
        .ignoresSafeArea()
        .frame(maxHeight: .infinity)
    }

    var centralContent: some View {
        VStack(alignment: .leading) {
            qrImage()
                .frame(width: fullScreenQrWidth, height: fullScreenQrWidth)
                .cornerRadius(8)
            Text(ShareLocalized.qrExplanation)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, .Global.contentHorizontalPadding)
    }

    var closeButton: some View {
        CircularButton {
            presentFullScreen = false
        } image: {
            Image(systemName: "xmark")
        }
        .padding(.horizontal, .Global.contentBottomPadding)
        .padding(.top, topPadding)
        .zIndex(100)
    }
}

extension View {
    fileprivate func darkBlurImageStyle(width: CGFloat) -> some View {
        self
            .scaledToFill()
            .frame(width: width)
            .blur(radius: 40, opaque: true)
            .overlay(content: {
                Color.black.opacity(0.2)
            })
    }
}

#Preview {
    let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")!
    GeometryReader { geometry in
        ShareQRFullScreenView(
            presentFullScreen: .constant(true),
            topPadding: geometry.safeAreaInsets.top,
            imageURL: imageURL,
            forceRefresh: .constant(false),
            windowWidth: geometry.size.width,
            qrImage: {
                Image.fallbakQRCodeImage
            }
        )
    }
}
