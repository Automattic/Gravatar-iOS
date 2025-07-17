import Gravatar
import SwiftUI

struct ShareHeaderView: View {
    let profile: Profile
    let topPadding: CGFloat
    let imageURL: URL?

    @Binding var forceRefresh: Bool

    @Environment(\.openURL) var openURL

    @State private var qrImage: UIImage?

    private let qrGenerator: QRGenerator
    private let horizontalSectionSpacing: CGFloat = 22

    @State private var buttonsSectionWidth: CGFloat = 0
    @State private var windowWidth: CGFloat = 0

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

    init(profile: Profile, topPadding: CGFloat, imageURL: URL?, forceRefresh: Binding<Bool>) {
        self.profile = profile
        self.topPadding = topPadding
        self.imageURL = imageURL
        self._forceRefresh = forceRefresh

        self.qrGenerator = QRGenerator(profile: profile)
    }

    var body: some View {
        BouncyImageBackgroundHeaderView(
            topPadding: topPadding,
            imageURL: imageURL,
            forceRefresh: $forceRefresh
        ) {
            HStack(alignment: .top, spacing: horizontalSectionSpacing) {
                VStack(alignment:.leading, spacing: .Global.contentSectionSpacing) {
                    qrCode
                    Text(Localized.qrExplanation)
                }
                VStack(spacing: 8) {
                    buttonsSection
                }.contentWidthtReader($buttonsSectionWidth)
            }
            .padding(.horizontal, .Global.contentHorizontalPadding)
        }
        .contentWidthtReader($windowWidth)
        .onAppear {
            Task {
                qrImage = await qrGenerator.contactQRCode
            }
        }
    }

    @ViewBuilder
    var qrCode: some View {
        if let qrImage {
            Image(uiImage: qrImage)
                .resizable()
                .frame(
                    width: qrWidth,
                    height: qrWidth
                )
                .cornerRadius(8)
        } else {
            ProgressView()
        }
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

        CircularButton {} image: {
            Image(.shareIcon)
        }
        CircularButton {} image: {
            Image(.downloadIcon)
        }
        CircularButton {} image: {
            Image(.enlargeIcon)
        }
    }
}

private enum Localized {
    static let qrExplanation = NSLocalizedString(
        "Share.Header.explanation",
        value: "Let others scan this QR code to share your contact information.",
        comment: "Message explaining what is the QR code for.")
}

#if DEBUG
#Preview {
    let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")
    GeometryReader { geo in
        ScrollView {
            ShareHeaderView(
                profile: .testProfile,
                topPadding:
                    geo.safeAreaInsets.top == 0 ?
                16 : geo.safeAreaInsets.top,
                imageURL: imageURL,
                forceRefresh: .constant(false)
            )
        }.ignoresSafeArea()
    }
}
#endif
