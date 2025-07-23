import Gravatar
import SwiftUI

struct ShareHeaderView<QRImage: View>: View {
    let profile: Profile
    let topPadding: CGFloat
    let imageURL: URL?

    @Binding var forceRefresh: Bool

    @Environment(\.openURL) var openURL

    let onShareButtonPressed: (() -> Void)?

    private var qrImage: () -> QRImage

    private let horizontalSectionSpacing: CGFloat = 22

    @State private var buttonsSectionWidth: CGFloat = 0
    @Binding private var windowWidth: CGFloat
    @State private var presentFullScreen: Bool = false

    var qrWidth: CGFloat {
        let padding = CGFloat.Global.contentHorizontalPadding
        // We need to set a fixed size for the image for Bouncy to calculate the content
        // height properly.
        // We also set a maximum size to not have huge QR codes on iPad.
        return min(
            windowWidth - buttonsSectionWidth - padding * 2 - horizontalSectionSpacing,
            350
        )
    }

    init(
        profile: Profile,
        qrImage: @escaping () -> QRImage,
        topPadding: CGFloat,
        imageURL: URL?,
        forceRefresh: Binding<Bool>,
        windowWidth: Binding<CGFloat>,
        onShareButtonPressed: (() -> Void)? = nil
    ) {
        self.profile = profile
        self.topPadding = topPadding
        self.imageURL = imageURL
        self._forceRefresh = forceRefresh
        self._windowWidth = windowWidth
        self.qrImage = qrImage
        self.onShareButtonPressed = onShareButtonPressed
    }

    var body: some View {
        BouncyImageBackgroundHeaderView(
            topPadding: topPadding,
            imageURL: imageURL,
            forceRefresh: $forceRefresh
        ) {
            HStack(alignment: .top, spacing: horizontalSectionSpacing) {
                VStack(alignment: .leading, spacing: .Global.verticalSectionSpacing) {
                    qrCode
                    Text(ShareLocalized.qrExplanation)
                }
                .padding(.top, .DS.Padding.half)
                VStack(spacing: 8) {
                    buttonsSection
                }.contentWidthtReader($buttonsSectionWidth)
            }
            .padding(.horizontal, .Global.contentHorizontalPadding)
        }
        .presentQRCodeFullScreen(
            presentFullScreen: $presentFullScreen,
            topPadding: topPadding,
            imageURL: imageURL,
            forceRefresh: $forceRefresh,
            windowWidth: windowWidth,
            qrImage: qrImage
        )
    }

    @ViewBuilder
    var qrCode: some View {
        qrImage()
            .frame(
                width: qrWidth,
                height: qrWidth
            )
            .cornerRadius(8)
    }

    @ViewBuilder
    var buttonsSection: some View {
        Menu {
            MainMenuOptions(profile: profile)
        } label: {
            EllipsisButton {}
        }
        // skip forced dark mode coming from parent view (Bouncy)
        .environment(\.colorScheme, UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light)

        CircularButton {
            onShareButtonPressed?()
        } image: {
            Image(.shareIcon)
        }
        CircularButton {} image: {
            Image(.downloadIcon)
        }
        CircularButton {
            presentFullScreen = true
        } image: {
            Image(.enlargeIcon)
        }
    }
}

enum ShareLocalized {
    static let qrExplanation = NSLocalizedString(
        "Share.Header.explanation",
        value: "Let others scan this QR code to share your contact information.",
        comment: "Message explaining what is the QR code for."
    )
}

extension View {
    @ViewBuilder
    fileprivate func presentQRCodeFullScreen(
        presentFullScreen: Binding<Bool>,
        topPadding: CGFloat = 0,
        imageURL: URL?,
        forceRefresh: Binding<Bool>,
        windowWidth: CGFloat,
        qrImage: @escaping () -> some View
    ) -> some View {
        let content = {
            ShareQRFullScreenView(
                presentFullScreen: presentFullScreen,
                topPadding: topPadding,
                imageURL: imageURL,
                forceRefresh: forceRefresh,
                windowWidth: windowWidth,
                qrImage: qrImage
            )
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.fullScreenCover(isPresented: presentFullScreen) {
                content()
            }
        } else {
            self.sheet(isPresented: presentFullScreen) {
                content()
            }
        }
    }
}

#if DEBUG
#Preview {
    let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")
    GeometryReader { geo in
        ScrollView {
            ShareHeaderView(
                profile: .testProfile,
                qrImage: { Image.fallbakQRCodeImage },
                topPadding:
                geo.safeAreaInsets.top == 0 ?
                    16 : geo.safeAreaInsets.top,
                imageURL: imageURL,
                forceRefresh: .constant(false),
                windowWidth: .constant(320)
            )
        }.ignoresSafeArea()
    }
}
#endif
