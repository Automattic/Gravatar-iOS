import Gravatar
import SwiftUI

class ShareViewModel: ObservableObject {
    let userSession: UserSession

    init(userSession: UserSession) {
        self.userSession = userSession
    }
}

struct ShareField: View {
    let title: String

    @Binding var value: String
    @Binding var selected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Public email")
                Toggle(isOn: $selected) { StyledTextField(value: $value, disabled: .constant(true)) }
            }
        }
    }
}

class ShareFieldsModel: ObservableObject {
    @AppStorage("shareEmail")
    var email: Bool = true
    @AppStorage("sharePhone")
    var phone: Bool = true
    @AppStorage("shareContactForm")
    var contactForm: Bool = true
}

struct ShareContent: View {
    @ObservedObject var viewModel: ShareViewModel
    @EnvironmentObject var userSession: UserSession

    @ObservedObject var shareFiedsModel = ShareFieldsModel()

    @State var forceRefresh: Bool = false
    @State var toggleOn: Bool = false

    @State var scrollOffset: CGFloat = 0
    @State var safeAreaInsets: EdgeInsets = .init()

    var email: String {
        userSession.profile.contactInfo?.email ?? ""
    }
    var phone: String {
        userSession.profile.contactInfo?.cellPhone ?? ""
    }
    var contactForm: String {
        userSession.profile.contactInfo?.contactForm ?? ""
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ShareHeaderView(forceRefresh: $forceRefresh, profile: userSession.profile, safeAreaInsets: $safeAreaInsets, width: geometry.size.width)
                    .transformEffect(.init(translationX: 0, y: -max(0, -scrollOffset)))
                    .frame(width: geometry.size.width)
                VStack(spacing: 16) {
                    ShareField(title: "Public email", value: .constant(email), selected: $shareFiedsModel.email)
                    ShareField(title: "Public phone", value: .constant(phone), selected: $shareFiedsModel.phone)
                    ShareField(title: "Public contact form", value: .constant(contactForm), selected: $shareFiedsModel.phone)
                }
                .padding()
                Spacer()
            }
            .scrollOffsetReader($scrollOffset)
            .scrollBounceBehavior(.basedOnSize)
            .ignoresSafeArea(.container, edges: [.top])
            // Safe area reader
            Color.clear
                .onAppear {
                    safeAreaInsets = geometry.safeAreaInsets
                }
                .onChange(of: geometry.frame(in: .global)) { _, _ in
                    safeAreaInsets = geometry.safeAreaInsets
                }
        }

        .onAppear {
            forceRefresh = true
        }
    }
}

extension View {
    func scrollOffsetReader(_ offset: Binding<CGFloat>) -> some View {
        if #available(iOS 18.0, *) {
            return self.onScrollGeometryChange(for: CGFloat.self, of: { geometry in
                geometry.contentOffset.y + geometry.contentInsets.top
            }, action: { _, newValue in
                offset.wrappedValue = newValue
            })
        } else {
            return self
        }
    }
}

struct ShareHeaderView: View {
    @EnvironmentObject var userSession: UserSession

    @Binding var forceRefresh: Bool

    let qrGenerator: QRGenerator
    @State var qrImage: UIImage?
    @State var contentHeight: CGFloat = 0
    @State var contentWidth: CGFloat = 0
    @Binding var safeAreaInsets: EdgeInsets
    let windowWidth: CGFloat

    private var imageURL: URL? {
        AvatarURL(
            with: .hashID(userSession.profile.hash),
            options: .init(preferredSize: .pixels(Int(contentWidth / 2)))
        )?.url
    }

    init(forceRefresh: Binding<Bool>, profile: Profile, safeAreaInsets: Binding<EdgeInsets>, width: CGFloat) {
        self._forceRefresh = forceRefresh
        self.qrGenerator = QRGenerator(profile: profile)
        self._safeAreaInsets = safeAreaInsets
        self.windowWidth = width
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
            .frame(maxHeight: UIScreen.main.bounds.height - safeAreaInsets.bottom)
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

#Preview {
    ShareContent(
        viewModel: .init(userSession: .init(profile: .testProfile, accessToken: ""))
    )
    .environmentObject(UserSession(profile: .testProfile, accessToken: ""))
}

import CoreImage.CIFilterBuiltins

struct QRGenerator: @unchecked Sendable {
    private let profile: Profile

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    init(profile: Profile) {
        self.profile = profile
    }

    var contactQRCode: UIImage {
        get async {
            await generateQRCode(from: "contact:\(profile.displayName)")
        }
    }

    private func generateQRCode(from string: String) async -> UIImage {
        await withCheckedContinuation { continuation in
            Task {
                filter.message = Data(string.utf8)

                if let outputImage = filter.outputImage {
                    let bigImage = outputImage.transformed(by: CGAffineTransform(scaleX: 20, y: 20))
                    if let cgImage = context.createCGImage(bigImage, from: bigImage.extent) {
                        let qrImage = UIImage(cgImage: cgImage)

                        continuation.resume(returning: qrImage)
                        return
                    }
                }

                let fallbackImage = UIImage(systemName: "xmark.circle") ?? UIImage()
                continuation.resume(returning: fallbackImage)
            }
        }
    }
}
