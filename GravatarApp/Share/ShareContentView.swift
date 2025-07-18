import Gravatar
import SwiftUI
import QuickLook

struct ShareContentView: View {
    @ObservedObject var viewModel: ShareViewModel

    var body: some View {
        VStack(spacing: 16) {
            sectionTitle(
                text: Localized.privateFieldsSectionTitle,
                image: .lock
            )

            privateSection

            Divider()
                .padding(.top)

            sectionTitle(
                text: Localized.gravatarFieldsSectionTitle,
                image: .gravatarLogo,
                imageColor: .DS.bluishColor
            )
            .padding(.vertical)

            gravatarFieldsSection(profile: viewModel.userSession.profile)

            Divider()
                .padding(.bottom)

            previewSection
        }
        .padding()
        .readableContentWidth()
    }

    @ViewBuilder
    var privateSection: some View {
        ShareTextField(
            text: viewModel.$storedUserEmail,
            placeholder: Localized.emailFieldTitle,
            selected: viewModel.share.$email
        )
        .keyboardType(.emailAddress)
        ShareTextField(
            text: viewModel.$storedPhoneNumber,
            placeholder: Localized.phoneNumberFieldTitle,
            selected: viewModel.share.$phone
        )
        .keyboardType(.phonePad)
    }

    @ViewBuilder
    func gravatarFieldsSection(profile: Profile) -> some View {
        ShareField(
            title: Localized.nameFieldTitle,
            value: profile.fullName ?? "",
            selected: viewModel.share.$name
        )
        .disabled(viewModel.userSession.profile.fullName == nil)
        Divider()
        ShareField(
            title: ProfileField.location.localizedTitle,
            value: viewModel.userSession.profile.location,
            selected: viewModel.share.$location
        )
        .disabled(profile.location.isEmpty)
        Divider()
        ShareField(
            title: ProfileField.jobTitle.localizedTitle,
            value: profile.jobTitle,
            selected: viewModel.share.$jobTitle
        )
        .disabled(profile.jobTitle.isEmpty)
        Divider()
        ShareField(
            title: ProfileField.aboutMe.localizedTitle,
            value: profile.description,
            selected: viewModel.share.$description
        )
        .disabled(profile.description.isEmpty)
    }

    @ViewBuilder
    var previewSection: some View {
        Text(Localized.previewSectionTitle)
            .font(.caption)
            .foregroundStyle(.secondary)

        Button(Localized.previewButtonTitle) {
            viewModel.previewVCard()
        }
        .buttonStyle(.actionButton())
    }

    func sectionTitle(text: String, image: ImageResource, imageColor: Color? = nil) -> some View {
        HStack {
            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
            Image(image)
                .padding(.trailing, 12)
                .if(imageColor) { view, color in
                    view.foregroundStyle(color)
                }
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        ShareContentView(
            viewModel: .init(userSession: .init(
                profile: .testProfile,
                accessToken: "",
                context: .testContext
            ))
        )
    }
}
#endif

private enum Localized {
    static let emailFieldTitle: String = NSLocalizedString(
        "Share.Contact.Email.title",
        value: "Email",
        comment: "Title for the email field to be shared via QR code"
    )

    static let phoneNumberFieldTitle: String = NSLocalizedString(
        "Share.Contact.PhoneNumber.title",
        value: "Phone number",
        comment: "Title for the phone number field to be shared via QR code"
    )

    static let nameFieldTitle: String = NSLocalizedString(
        "Share.Contact.Name.title",
        value: "Name",
        comment: "Title for the name field to be shared via QR code"
    )

    static let privateFieldsSectionTitle: String = NSLocalizedString(
        "Share.Contact.PrivateSection.title",
        value: "Share private contact info.",
        comment: "Title for the section with the private contact info."
    )

    static let gravatarFieldsSectionTitle: String = NSLocalizedString(
        "Share.Contact.GravatarFieldsSection.title",
        value: "Share info from your Gravatar profile.",
        comment: "Title for the section with the public Gravatar contact info."
    )

    static let previewSectionTitle: String = NSLocalizedString(
        "Share.Contact.Preview.title",
        value: "See what others will see when they scan your QR code.",
        comment: "Title for the preview section."
    )

    static let previewButtonTitle: String = NSLocalizedString(
        "Share.Contact.Preview.Button.title",
        value: "Preview",
        comment: "Title for the preview vCard button."
    )
}
