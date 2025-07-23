import Gravatar
import QuickLook
import SwiftUI

struct ShareView: View {
    @ObservedObject var viewModel: ShareViewModel

    @Binding var forceRefreshAvatar: Bool

    var headerAvatarURL: URL? {
        AvatarURL.preferredURL(for: viewModel.profile.hash)
    }

    @ViewBuilder
    var qrImage: some View {
        if let qrCode = viewModel.qrCodeImage {
            qrCode
        } else {
            Image.fallbakQRCodeImage
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
                    forceRefresh: $forceRefreshAvatar,
                    onShareButtonPressed: onShareButtonPressed
                )

                ShareContentView(viewModel: viewModel)
            }
            .ignoresSafeArea(.container, edges: [.top, .horizontal])
            .scrollDismissesKeyboard(.interactively)
        }
        .quickLookPreview($viewModel.contactPreviewURL)
        .sheet(item: $viewModel.shareVCardURL) { url in
            ShareSheet(items: [url])
                .presentationDetents([.medium, .large])
        }
        .onChange(of: forceRefreshAvatar) { _, newValue in
            if newValue {
                viewModel.refreshUserAvatar()
            }
        }
    }

    func onShareButtonPressed() {
        Task {
            await viewModel.shareVCard()
        }
    }
}

extension URL: @retroactive Identifiable {
    public var id: String {
        self.absoluteString
    }
}

#if DEBUG
#Preview {
    ShareView(
        viewModel: .init(userSession: .init(
            profile: .testProfile,
            accessToken: "",
            context: .testContext
        )),
        forceRefreshAvatar: .constant(false)
    )
}
#endif
