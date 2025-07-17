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

    var headerAvatarURL: URL? {
        AvatarURL(
            with: .hashID(viewModel.userSession.profile.hash),
            options: .init(preferredSize: .pixels(256))
        )?.url
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ShareHeaderView(
                    profile: userSession.profile,
                    topPadding: geometry.safeAreaInsets.top,
                    imageURL: headerAvatarURL,
                    forceRefresh: $forceRefresh
                )
                VStack(spacing: 16) {
                    ShareField(
                        title: Localized.emailFieldTitle,
                        value: userEmail,
                        selected: viewModel.share.$email
                    )
                    ShareField(
                        title: Localized.phoneNumberFieldTitle,
                        value: userPhone,
                        selected: viewModel.share.$phone
                    )
                    ShareField(
                        title: Localized.contactFieldTitle,
                        value: userContactForm,
                        selected: viewModel.share.$contactForm
                    )
                }
                .padding()
                Spacer()
            }
            .ignoresSafeArea(.container, edges: [.top])
        }
    }
}

#if DEBUG
#Preview {
    ShareContentView(
        viewModel: .init(userSession: .init(profile: .testProfile, accessToken: "", context: .testContext))
    )
    .environmentObject(UserSession(profile: .testProfile, accessToken: "", context: .testContext))
}
#endif

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
