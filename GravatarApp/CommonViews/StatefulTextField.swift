import SwiftUI

private enum StatefulTextFieldConstants {
    static let textInputFont: Font = .body
    static let textInputCornerRadius: CGFloat = 8
    static let textBackgroundColor: UIColor = .tertiarySystemFill
    static let fieldVerticalPadding: CGFloat = 10
    static let focusedTextBorderColor: UIColor = .rgba(27, 78, 196)
}

struct StatefulTextField: View {
    fileprivate typealias Constants = StatefulTextFieldConstants

    /// Whether to use a multiline/singleline text input
    let isLarge: Bool
    /// The accessibilityLabel
    let accessibilityLabel: String
    /// Used to identify the focused field on the parent
    let fieldIdentifier: String
    /// Value of the text input
    @Binding var value: String
    /// If the text input should be disabled
    let isDisabled: () -> Bool
    /// If the text has unsaved changes
    let hasUnsavedChanges: () -> Bool
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        if isLarge {
            TextEditor(text: $value)
                .font(Constants.textInputFont)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, .DS.Padding.single)
                .frame(height: dynamicTypeSize >= .accessibility1 ? 150 : 120)
                .disabled(isDisabled())
                .accessibilityLabel(accessibilityLabel)
                .padding(.vertical, 0)
                .backgroundColor(hasUsavedChanges: hasUnsavedChanges())
                .scrollContentBackground(.hidden)
                .cornerRadius(Constants.textInputCornerRadius)
                .focused($isFocused)
                .focusedBorder(isFocused: isFocused)
                .focusedValue(\.focusedField, isFocused ? fieldIdentifier : nil)
        } else {
            TextField(
                "",
                text: $value
            )
            .font(Constants.textInputFont)
            .padding(.DS.Padding.split)
            .disabled(isDisabled())
            .accessibilityLabel(accessibilityLabel)
            .backgroundColor(hasUsavedChanges: hasUnsavedChanges())
            .cornerRadius(Constants.textInputCornerRadius)
            .focused($isFocused)
            .focusedBorder(isFocused: isFocused)
            .focusedValue(\.focusedField, isFocused ? fieldIdentifier : nil)
        }
    }
}

extension View {
    fileprivate func focusedBorder(
        isFocused: Bool
    ) -> some View {
        self.shape(
            RoundedRectangle(cornerRadius: StatefulTextFieldConstants.textInputCornerRadius),
            borderColor: Color(uiColor: StatefulTextFieldConstants.focusedTextBorderColor),
            borderWidth: isFocused ? 2 : 0
        )
    }

    fileprivate func backgroundColor(
        hasUsavedChanges: Bool
    ) -> some View {
        self
            .background(
                hasUsavedChanges ?
                    Color(uiColor: StatefulTextFieldConstants.focusedTextBorderColor).opacity(0.1) :
                    Color(uiColor: StatefulTextFieldConstants.textBackgroundColor)
            )
    }
}

struct FocusedFieldKey: FocusedValueKey {
    typealias Value = String
}

extension FocusedValues {
    var focusedField: String? {
        get { self[FocusedFieldKey.self] }
        set { self[FocusedFieldKey.self] = newValue }
    }
}

#Preview {
    StatefulTextField(
        isLarge: false,
        accessibilityLabel: "Accessibility Label",
        fieldIdentifier: "name",
        value: .constant("value"),
        isDisabled: { false },
        hasUnsavedChanges: { false }
    )
}
