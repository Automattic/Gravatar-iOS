import Gravatar
import QuickLook
import SwiftUI

struct ShareView: View {
    @ObservedObject var viewModel: ShareViewModel

    @State var forceRefresh: Bool = false

    var headerAvatarURL: URL? {
        AvatarURL(
            with: .hashID(viewModel.profile.hash),
            options: .init(preferredSize: .pixels(256))
        )?.url
    }

    @ViewBuilder
    var qrImage: some View {
        if let qrCode = viewModel.qrCodeImage {
            qrCode
        } else {
            QRGenerator.fallbakImage
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ShareHeaderView(
                    profile: viewModel.profile,
                    qrImage: { qrImage },
                    topPadding: geometry.safeAreaInsets.top,
                    imageURL: headerAvatarURL,
                    forceRefresh: $forceRefresh
                )

                ShareContentView(viewModel: viewModel)
            }
            .ignoresSafeArea(.container, edges: [.top, .horizontal])
            .scrollDismissesKeyboard(.interactively)
        }
        .quickLookPreview($viewModel.contactPreviewURL)
    }
}

#if DEBUG
#Preview {
    ShareView(
        viewModel: .init(userSession: .init(
            profile: .testProfile,
            accessToken: "",
            context: .testContext
        ))
    )
}
#endif
