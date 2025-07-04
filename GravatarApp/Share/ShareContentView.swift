import Gravatar
import SwiftUI

struct ShareContentView: View {
    @ObservedObject var viewModel: ShareViewModel
    @EnvironmentObject var userSession: UserSession

    @State var forceRefresh: Bool = false
    @State var toggleOn: Bool = false

    @State var scrollOffset: CGFloat = 0
    @State var safeAreaInsets: EdgeInsets = .init()

    var userEmail: String {
        userSession.profile.contactInfo?.email ?? ""
    }

    var userPhone: String {
        userSession.profile.contactInfo?.cellPhone ?? ""
    }

    var userContactForm: String {
        userSession.profile.contactInfo?.contactForm ?? ""
    }

    @State var isFirstAppear = true

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ShareHeaderView(
                    forceRefresh: $forceRefresh,
                    profile: userSession.profile,
                    safeAreaInsets: $safeAreaInsets,
                    width: geometry.size.width,
                    maxHeight: geometry.size.height
                )
                // Sticky header on scroll bounce
                .transformEffect(.init(translationX: 0, y: -max(0, -scrollOffset)))
                .frame(width: geometry.size.width)
                VStack(spacing: 16) {
                    ShareField(
                        title: Localized.emailFieldTitle,
                        value: .constant(userEmail),
                        selected: viewModel.share.$email
                    )
                    ShareField(
                        title: Localized.phoneNumberFieldTitle,
                        value: .constant(userPhone),
                        selected: viewModel.share.$phone
                    )
                    ShareField(
                        title: Localized.contactFieldTitle,
                        value: .constant(userContactForm),
                        selected: viewModel.share.$contactForm
                    )
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
            guard !isFirstAppear else {
                isFirstAppear = false
                // Skip refresh on first appear, since the image loads from url.
                return
            }
            // Refreshing in consecuent appear in case image selection has changed.
            forceRefresh = true
        }
    }
}

#Preview {
    ShareContentView(
        viewModel: .init(userSession: .init(profile: .testProfile, accessToken: ""))
    )
    .environmentObject(UserSession(profile: .testProfile, accessToken: ""))
}

private enum Localized {
    static let emailFieldTitle: String = NSLocalizedString(
        "Share.Contact.Email.title",
        value: "Public email",
        comment: "Title for the email field to be shared via QR code"
    )

    static let phoneNumberFieldTitle: String = NSLocalizedString(
        "Share.Contact.PhoneNumber.title",
        value: "Public phone number",
        comment: "Title for the phone number field to be shared via QR code"
    )

    static let contactFieldTitle: String = NSLocalizedString(
        "Share.Contact.ContactField.title",
        value: "Contact page",
        comment: "Title for the contact form url field to be shared via QR code"
    )
}
