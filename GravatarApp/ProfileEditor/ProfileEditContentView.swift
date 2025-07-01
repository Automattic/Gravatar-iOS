import Analytics
import Gravatar
import SwiftUI

struct ProfileEditContentView: View {
    private enum Constants {
        static let primaryFont: Font = .subheadline
        static let sectionHeaderFont: Font = .subheadline.weight(.semibold)
        static let footerFont: Font = .footnote
        static let horizontalPadding: CGFloat = .DS.Padding.double
        static let vStackVerticalSpacing: CGFloat = .DS.Padding.medium
    }

    @ObservedObject var viewModel: EditProfileViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        VStack {
            Text("Profile Editor!")

            // Add some content to make it scroll
            ForEach(1 ... 50, id: \.self) { i in
                Text("Item \(i)")
                    .font(.system(size: 16))
            }
        }
        .padding()
    }

    private func saveButton() -> some View {
        ZStack {
            Button {
                Task {
                    isSaving = true
                    if let profile = await self.model.saveAboutInfo(for: fields) {
                        aboutUpdateHandler?(profile)
                    }
                    isSaving = false
                }
            } label: {
                CTAButtonView(Localized.saveButtonTitle)
            }
            .disabled(!model.hasUnsavedChanges || isSaving)
            if isSaving {
                ProgressView()
            }
        }
    }

    @ViewBuilder
    private func personal() -> some View {
        inputField(
            for: ProfileEditLocalization.displayName,
            value: $viewModel.fields.displayName
        )
        inputField(
            for: ProfileEditLocalization.firstName,
            value: $viewModel.fields.firstName
        )
        inputField(
            for: ProfileEditLocalization.lastName,
            value: $viewModel.fields.lastName
        )
        inputField(
            for: ProfileEditLocalization.aboutMe,
            footerText: AttributedString(ProfileEditLocalization.aboutMeFooterText),
            value: $viewModel.fields.aboutMe,
            isLarge: true
        )
        inputField(
            for: ProfileEditLocalization.pronunciation,
            footerText: AttributedString(ProfileEditLocalization.pronunciationFooterText),
            value: $viewModel.fields.pronunciation
        )
        inputField(
            for: ProfileEditLocalization.pronouns,
            value: $viewModel.fields.pronouns
        )
        inputField(
            for: ProfileEditLocalization.location,
            value: $viewModel.fields.location
        )
    }

    @ViewBuilder
    private func professional() -> some View {
        sectionHeader(title: ProfileEditLocalization.professionalSectionHeader)
        inputField(
            for: ProfileEditLocalization.jobTitle,
            value: $viewModel.fields.jobTitle
        )
        inputField(
            for: ProfileEditLocalization.company,
            value: $viewModel.fields.company
        )
    }

    @ViewBuilder
    private func contact() -> some View {
        sectionHeader(title: ProfileEditLocalization.contactSectionHeader)
        inputField(
            for: ProfileEditLocalization.contactEmail,
            value: $viewModel.fields.contactEmail
        )
        inputField(
            for: ProfileEditLocalization.phone,
            value: $viewModel.fields.cellPhone
        )
    }

    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(Constants.sectionHeaderFont)
            .multilineTextAlignment(.leading)
            .padding(.bottom, .DS.Padding.single)
    }

    private func inputField(
        for title: String,
        footerText: AttributedString? = nil,
        value: Binding<String>,
        isLarge: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: .DS.Padding.single) {
            Text(title)
                .font(Constants.primaryFont)
                .multilineTextAlignment(.leading)
                .accessibilityHidden(true)
            if isLarge {
                TextEditor(text: value)
                    .font(Constants.primaryFont)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, .DS.Padding.single)
                    .padding(.vertical, 0)
                    .inputBorders(colorScheme: colorScheme)
                    .frame(height: dynamicTypeSize >= .accessibility1 ? 150 : 120)
                    .disabled(viewModel.isSaving)
                    .accessibilityLabel(title)
            } else {
                TextField(
                    "",
                    text: value
                )
                .font(Constants.primaryFont)
                .padding(.DS.Padding.split)
                .inputBorders(colorScheme: colorScheme)
                .disabled(viewModel.isSaving)
                .accessibilityLabel(title)
            }

            if let footerText {
                Text(footerText)
                    .font(Constants.footerFont)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
            }
        }
        .padding(.vertical, .DS.Padding.single)
        .frame(maxWidth: .infinity)
    }
}

extension View {
    fileprivate func inputBorders(colorScheme: ColorScheme) -> some View {
        self.shape(
            RoundedRectangle(cornerRadius: 2),
            borderColor: Color(uiColor: .label).opacity(colorScheme == .dark ? 0.30 : 0.15),
            borderWidth: 1
        )
    }
}
