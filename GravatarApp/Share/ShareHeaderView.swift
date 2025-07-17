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

    @State private var buttonsSectionWidth: CGFloat = 0
    @State private var windowWidth: CGFloat = 0

    var qrWidth: CGFloat {
        min(windowWidth - buttonsSectionWidth - 32 - 22, 350)
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
            HStack(alignment: .top, spacing: 22) {
                VStack(alignment:.leading, spacing: 16) {
                    qrCode
                    Text("Let others scan this QR code to share your contact information.")
                    Text("buttonsWidth: \(buttonsSectionWidth)")
                    Text("windowWidth: \(windowWidth)")
                    Text("qrWidth: \(qrWidth)")
                }
                VStack(spacing: 8) {
                    buttonsSection
                }.contentWidthtReader($buttonsSectionWidth)
            }
            .padding(.horizontal, 16)
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
