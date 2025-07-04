import SwiftUI
import Gravatar

struct ShareHeaderView: View {
    @EnvironmentObject var userSession: UserSession

    @Binding var forceRefresh: Bool

    let qrGenerator: QRGenerator
    @State var qrImage: UIImage?
    @State var contentHeight: CGFloat = 0
    @State var contentWidth: CGFloat = 0
    @Binding var safeAreaInsets: EdgeInsets
    let windowWidth: CGFloat
    let maxHeight: CGFloat

    private var imageURL: URL? {
        AvatarURL(
            with: .hashID(userSession.profile.hash),
            options: .init(preferredSize: .pixels(Int(contentWidth / 2)))
        )?.url
    }

    init(
        forceRefresh: Binding<Bool>,
        profile: Profile,
        safeAreaInsets: Binding<EdgeInsets>,
        width: CGFloat,
        maxHeight: CGFloat
    ) {
        self._forceRefresh = forceRefresh
        self.qrGenerator = QRGenerator(profile: profile)
        self._safeAreaInsets = safeAreaInsets
        self.windowWidth = width
        self.maxHeight = maxHeight
    }

    var body: some View {
        ZStack(alignment: .top) {
            backgroundImageView(
                imageURL: imageURL
            )
            .frame(height: contentHeight)
            .clipped()
            backgroundMaterial

            VStack(spacing: 16) {
                Text("Quickly share your public contact info by letting other scan this QR code.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                    .frame(width: windowWidth)
                    .padding()

                if let qrImage {
                    Image(uiImage: qrImage)
                        .resizable()
                        .frame(
                            maxWidth: min(windowWidth - 24, 400),
                            maxHeight: min(windowWidth - 24, 400)
                        )
                        .scaledToFit()
                        .cornerRadius(20)
                        .padding(.bottom, 24)
                } else {
                    ProgressView()
                }
            }
            .padding(.leading, safeAreaInsets.leading == 0 ? 24 : safeAreaInsets.leading)
            .padding(.trailing, safeAreaInsets.trailing == 0 ? 24 : safeAreaInsets.trailing)
            .padding(.top, safeAreaInsets.top == 0 ? 16 : safeAreaInsets.top)
            .overlay(GeometryReader { geo in
                Color.clear
                    .onChange(of: geo.size) { _, newValue in
                        contentHeight = newValue.height
                    }
            })
            .frame(maxHeight: maxHeight)
        }
        .overlay(GeometryReader { geo in
            Color.clear
                .onChange(of: geo.size) { _, newValue in
                    contentWidth = newValue.width
                }
        })
        .onAppear {
            Task {
                qrImage = await qrGenerator.contactQRCode
            }
        }
    }

    private func backgroundImageView(imageURL: URL?) -> some View {
        HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
            Color.clear
        }
        .scaledToFill()
        .clipped()
    }

    private var backgroundMaterial: some View {
        Color.clear
            .ignoresSafeArea()
            .background(.ultraThinMaterial)
            .frame(width: contentWidth, height: contentHeight)
            .environment(\.colorScheme, .dark)
    }
}

#if DEBUG
#Preview {
    GeometryReader { geometry in
        ScrollView {
            ShareHeaderView(
                forceRefresh: .constant(false),
                profile: .testProfile,
                safeAreaInsets: .constant(geometry.safeAreaInsets),
                width: geometry.size.width,
                maxHeight: geometry.size.height
            )
            .environmentObject(UserSession(profile: .testProfile, accessToken: ""))
            .frame(width: geometry.size.width)
        }
        .ignoresSafeArea()
    }
}
#endif
