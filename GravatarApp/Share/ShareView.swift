import Gravatar
import QuickLook
import SwiftUI

struct ShareView: View {
    @ObservedObject var viewModel: ShareViewModel

    @Binding var forceRefreshAvatar: Bool
    @State private var scrollOffset: CGFloat = 0
    @State private var windowWidth: CGFloat = 0
    @State private var safeAreaInsets: EdgeInsets = .init()
    @Environment(\.analytics) private var analytics

    var headerAvatarURL: URL? {
        AvatarURL.preferredURL(for: viewModel.profile.hash)
    }

    var topPadding: CGFloat {
        safeAreaInsets.top > 0 ? topPaddingCompensation : .Global.verticalSectionSpacing
    }

    private var topPaddingCompensation: CGFloat {
        safeAreaInsets.top > 0 && safeAreaInsets.top <= 20 ? 4 : 0
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
                OffsetReaderView(scrollOffset: $scrollOffset)
                ShareHeaderView(
                    profile: viewModel.profile,
                    qrImage: { qrImage },
                    topPadding: topPadding,
                    imageURL: headerAvatarURL,
                    forceRefresh: $forceRefreshAvatar,
                    windowWidth: $windowWidth,
                    onShareButtonPressed: onShareButtonPressed,
                    onMainMenuButtonPressed: {
                        analytics.track(QRScreenEvents.mainMenuTapped)
                    },
                    onFullScreenButtonPressed: {
                        analytics.track(QRScreenEvents.headerExpandTapped)
                    }
                )
                ShareContentView(viewModel: viewModel)
            }
            .ignoresSafeArea(.container, edges: [.horizontal])
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: geometry.safeAreaInsets) { _, newValue in
                safeAreaInsets = newValue
            }
            .onChange(of: geometry.size) { _, value in
                windowWidth = value.width
            }
            .onAppear {
                windowWidth = geometry.size.width
            }
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
        .overlay(content: {
            VStack {
                Rectangle().fill(Color.clear)
                    .background(.ultraThinMaterial)
                    .frame(height: safeAreaInsets.top)
                    .ignoresSafeArea()
                    .opacity(scrollOffset < -.DS.Padding.single ? 1 : 0)
                    .animation(.snappy(duration: 0.3), value: scrollOffset)
                    .environment(\.colorScheme, .dark)
                Spacer()
            }
        })
        .onAppear {
            analytics.track(QRScreenEvents.screenView)
        }
        .onDisappear {
            analytics.track(QRScreenEvents.screenLeave)
        }
    }

    func onShareButtonPressed() {
        analytics.track(QRScreenEvents.headerShareTapped)
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
