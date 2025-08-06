import Gravatar
import QuickLook
import SwiftUI

struct ShareContentView: View {
    @ObservedObject var viewModel: ShareViewModel
    @FocusState var focusState: Bool
    @EnvironmentObject var modalManager: ModalPresentationManager

    var body: some View {
        VStack(spacing: .Global.verticalSectionSpacing) {
            sectionTitle(
                text: Localized.privateFieldsSectionTitle,
                image: .lock,
                showExclamationButton: true
            )

            privateSection

            Divider()
                .padding(.top)

            sectionTitle(
                text: Localized.gravatarFieldsSectionTitle,
                image: .gravatarTab,
                imageColor: .DS.bluishColor
            )
            .padding(.vertical)

            gravatarFieldsSection(profile: viewModel.profile)

            Divider()
                .padding(.bottom)

            previewSection
        }
        .padding()
        .readableContentWidth()
        .onChange(of: focusState) { oldValue, newValue in
            if oldValue && !newValue {
                Task {
                    await viewModel.generateVCardQR()
                }
            }
        }
    }

    @ViewBuilder
    var privateSection: some View {
        ShareTextField(
            text: $viewModel.storedUserEmail,
            placeholder: Localized.emailFieldTitle,
            selected: $viewModel.share.email
        )
        .textContentType(.emailAddress)
        .keyboardType(.emailAddress)
        .autocorrectionDisabled()
        .autocapitalization(.none)
        .focused($focusState, equals: true)

        ShareTextField(
            text: $viewModel.storedPhoneNumber,
            placeholder: Localized.phoneNumberFieldTitle,
            selected: $viewModel.share.phone
        )
        .keyboardType(.phonePad)
        .focused($focusState, equals: true)
    }

    @ViewBuilder
    func gravatarFieldsSection(profile: Profile) -> some View {
        if let fullName = profile.fullName, !fullName.isEmpty {
            ShareField(
                title: Localized.nameFieldTitle,
                value: profile.fullName ?? "",
                selected: $viewModel.share.name
            )
            .disabled(viewModel.profile.fullName == nil)
            Divider()
        }
        if !profile.location.isEmpty {
            ShareField(
                title: ProfileField.location.localizedTitle,
                value: viewModel.profile.location,
                selected: $viewModel.share.location
            )
            .disabled(profile.location.isEmpty)
            Divider()
        }
        if !profile.jobTitle.isEmpty {
            ShareField(
                title: ProfileField.jobTitle.localizedTitle,
                value: profile.jobTitle,
                selected: $viewModel.share.jobTitle
            )
            .disabled(profile.jobTitle.isEmpty)
            Divider()
        }
        if !profile.company.isEmpty {
            ShareField(
                title: ProfileField.company.localizedTitle,
                value: profile.company,
                selected: $viewModel.share.company
            )
            .disabled(profile.jobTitle.isEmpty)
            Divider()
        }
        if !profile.description.isEmpty {
            ShareField(
                title: ProfileField.aboutMe.localizedTitle,
                value: profile.description,
                selected: $viewModel.share.description
            )
            .disabled(profile.description.isEmpty)
            Divider()
        }
        ShareField(
            title: Localized.profileURLFieldTitle,
            value: cleanURL(profile.profileUrl),
            selected: $viewModel.share.profileURL
        )

        ForEach(profile.verifiedAccounts, id: \.self) { account in
            Divider()
            ShareField(
                title: Localized.accountNameFieldTitle(for: account.serviceLabel),
                value: cleanURL(account.url),
                selected: Binding(get: {
                    viewModel.share.account(account)
                }, set: { newValue in
                    viewModel.share.set(account, to: newValue)
                })
            )
        }
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

    func sectionTitle(
        text: String,
        image: ImageResource,
        imageColor: Color? = nil,
        showExclamationButton: Bool = false
    ) -> some View {
        Button {
            modalManager.present {
                PrivateInformationAlertView(onDismiss: {
                    modalManager.dismiss()
                })
            }
        } label: {
            HStack {
                Image(image)
                    .if(imageColor) { view, color in
                        view.foregroundStyle(color)
                    }
                    .foregroundStyle(Color.black)
                Text(text)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                if showExclamationButton {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .padding(.trailing, 16)
                }
            }
        }
        .foregroundStyle(.secondary)
        .disabled(!showExclamationButton)
    }

    private func cleanURL(_ url: String) -> String {
        url.replacingOccurrences(of: "https://", with: "")
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
        .environmentObject(ModalPresentationManager())
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

    static let profileURLFieldTitle: String = NSLocalizedString(
        "Share.Contact.ProfileURL.title",
        value: "Profile URL",
        comment: "Title for the profile url field to be shared via QR code"
    )

    static func accountNameFieldTitle(for serviceLabel: String) -> String {
        String(format: NSLocalizedString(
            "Share.Contact.Account.title",
            value: "%@ account",
            comment: "Title for the account url field. %@ is the service label. e.g. 'WordPress account'."
        ), serviceLabel)
    }

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
