import Analytics
import Gravatar
import SwiftUI

struct ProfileEditContentView: View {
    fileprivate enum Constants {
        static let textTitleFont: Font = .callout
        static let textInputFont: Font = .body
        static let textInputCornerRadius: CGFloat = 8
        static let sectionHeaderFont: Font = .title2.weight(.semibold)
        static let footerFont: Font = .footnote
        static let textBackgroundColor: UIColor = .tertiarySystemFill
        static let fieldVerticalPadding: CGFloat = 10
        static let focusedTextBorderColor: UIColor = .rgba(27, 78, 196)
    }

    @ObservedObject var viewModel: EditProfileViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @FocusedValue(\.focusedField) private var focusedField

    var body: some View {
        content()
            .background(Color(uiColor: UIColor.secondarySystemBackground))
    }

    @ViewBuilder
    private func content() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            personal()
            Spacer().frame(height: .DS.Padding.medium)
            professional()
        }
        .padding(.DS.Padding.double)
    }

    @ViewBuilder
    private func personal() -> some View {
        inputField(
            .displayName,
            value: $viewModel.fields.displayName
        )
        inputField(
            .firstName,
            value: $viewModel.fields.firstName
        )
        inputField(
            .lastName,
            value: $viewModel.fields.lastName
        )
        inputField(
            .pronunciation,
            footerText: AttributedString(ProfileEditLocalization.pronunciationFooterText),
            value: $viewModel.fields.pronunciation
        )
        inputField(
            .pronouns,
            value: $viewModel.fields.pronouns
        )
        inputField(
            .location,
            value: $viewModel.fields.location
        )
        inputField(
            .aboutMe,
            footerText: AttributedString(ProfileEditLocalization.aboutMeFooterText),
            value: $viewModel.fields.aboutMe,
            isLarge: true
        )
    }

    @ViewBuilder
    private func professional() -> some View {
        sectionHeader(title: ProfileEditLocalization.professionalSectionHeader)
        inputField(
            .jobTitle,
            value: $viewModel.fields.jobTitle
        )
        inputField(
            .company,
            value: $viewModel.fields.company
        )
    }

    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(Constants.sectionHeaderFont)
            .multilineTextAlignment(.leading)
            .padding(.bottom, .DS.Padding.single)
    }

    private func inputField(
        _ field: ProfileField,
        footerText: AttributedString? = nil,
        value: Binding<String>,
        isLarge: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: .DS.Padding.single) {
            Text(field.localizedTitle)
                .font(Constants.textTitleFont)
                .multilineTextAlignment(.leading)
                .accessibilityHidden(true)

            StatefulTextField(
                isLarge: isLarge,
                accessibilityLabel: field.localizedTitle,
                fieldIdentifier: field.rawValue,
                value: value,
                isDisabled: { viewModel.isSaving },
                hasUnsavedChanges: { viewModel.hasDifference(in: field) }
            )

            if let footerText {
                Text(footerText)
                    .font(Constants.footerFont)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
            }
        }
        .padding(.vertical, Constants.fieldVerticalPadding)
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG // Needed when we use `Profile.testProfile on Previews`
#Preview {
    ScrollView {
        ProfileEditContentView(viewModel: .init(userSession: .init(profile: .testProfile, accessToken: "", context: .testContext)))
    }
}
#endif
