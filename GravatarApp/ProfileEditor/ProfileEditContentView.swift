import Analytics
import Gravatar
import SwiftUI

struct ProfileEditContentView: View {
    private enum Constants {
        static let textTitleFont: Font = .callout
        static let textInputFont: Font = .body
        static let textInputCornerRadius: CGFloat = 8
        static let sectionHeaderFont: Font = .title2.weight(.semibold)
        static let footerFont: Font = .footnote
        static let textBackgroundColor: UIColor = .tertiarySystemFill
        static let fieldVerticalPadding: CGFloat = 10
    }

    @ObservedObject var viewModel: EditProfileViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        content()
            .background(Color(uiColor: UIColor.secondarySystemBackground))
    }

    @ViewBuilder
    private func content() -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                personal()
                Spacer().frame(height: .DS.Padding.medium)
                professional()
            }
            .fixedSize(horizontal: false, vertical: true)
            saveButton()
                .padding(.top, .DS.Padding.double)
        }
        .padding(.DS.Padding.double)
    }

    private func saveButton() -> some View {
        ZStack {
            Button {
                Task {
                    await self.viewModel.save()
                }
            } label: {
                Text(ProfileEditLocalization.saveButtonTitle)
                    .font(.callout).fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding(.vertical, .DS.Padding.split)
                    .padding(.horizontal, .DS.Padding.double)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(uiColor: viewModel.isSavinDisabled ? UIColor.systemFill : UIColor.tintColor))
                    )
            }
            .disabled(viewModel.isSavinDisabled)
            if viewModel.isSaving {
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
        inputField(
            for: ProfileEditLocalization.aboutMe,
            footerText: AttributedString(ProfileEditLocalization.aboutMeFooterText),
            value: $viewModel.fields.aboutMe,
            isLarge: true
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
                .font(Constants.textTitleFont)
                .multilineTextAlignment(.leading)
                .accessibilityHidden(true)
            if isLarge {
                TextEditor(text: value)
                    .font(Constants.textInputFont)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, .DS.Padding.single)
                    .frame(height: dynamicTypeSize >= .accessibility1 ? 150 : 120)
                    .disabled(viewModel.isSaving)
                    .accessibilityLabel(title)
                    .padding(.vertical, 0)
                    .background(Color(uiColor: Constants.textBackgroundColor))
                    .scrollContentBackground(.hidden)
                    .cornerRadius(Constants.textInputCornerRadius)
            } else {
                TextField(
                    "",
                    text: value
                )
                .font(Constants.textInputFont)
                .padding(.DS.Padding.split)
                .disabled(viewModel.isSaving)
                .accessibilityLabel(title)
                .background(Color(uiColor: Constants.textBackgroundColor))
                .cornerRadius(Constants.textInputCornerRadius)
            }

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

extension View {
    private func inputBorders(colorScheme: ColorScheme) -> some View {
        self.shape(
            RoundedRectangle(cornerRadius: 2),
            borderColor: Color(uiColor: .label).opacity(colorScheme == .dark ? 0.30 : 0.15),
            borderWidth: 1
        )
    }
}

#if DEBUG // Needed when we use `Profile.testProfile on Previews`
#Preview {
    ScrollView {
        ProfileEditContentView(viewModel: .init(userSession: .init(profile: .testProfile, accessToken: "")))
    }
}
#endif
