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
    let accessibilityLabel: String?
    /// Used to identify the focused field on the parent
    let fieldIdentifier: String
    /// Placeholder text
    let placeholder: String?
    /// Value of the text input
    @Binding var value: String
    /// If the text has unsaved changes
    let hasUnsavedChanges: (() -> Bool)?
    /// To mock the focused state for unit testing
    let forceFocusedState: Bool

    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.isEnabled) var isEnabled

    init(
        isLarge: Bool = false,
        fieldIdentifier: String,
        placeholder: String? = nil,
        value: Binding<String>,
        accessibilityLabel: String? = nil,
        hasUnsavedChanges: (() -> Bool)? = nil,
        forceFocusedState: Bool = false
    ) {
        self.isLarge = isLarge
        self.accessibilityLabel = accessibilityLabel
        self.fieldIdentifier = fieldIdentifier
        self.placeholder = placeholder
        self._value = value
        self.hasUnsavedChanges = hasUnsavedChanges
        self.forceFocusedState = forceFocusedState
        self.isFocused = isFocused
    }

    var body: some View {
        Group {
            if isLarge {
                TextEditor(text: $value)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, .DS.Padding.single)
                    .frame(height: dynamicTypeSize >= .accessibility1 ? 150 : 120)
                    .padding(.vertical, 0)
                    .scrollContentBackground(.hidden)
            } else {
                TextField(
                    placeholder ?? "",
                    text: $value
                )
                .padding(.DS.Padding.split)
            }
        }
        .font(Constants.textInputFont)
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel ?? placeholder ?? "")
        .background(backgroundColor)
        .cornerRadius(Constants.textInputCornerRadius)
        .focused($isFocused)
        .focusedBorder(isFocused: shouldShowFocusedStyle)
        .focusedValue(\.focusedField, isFocused ? fieldIdentifier : nil)
        .opacity(isEnabled ? 1 : 0.3)
    }

    private var shouldShowFocusedStyle: Bool {
        isFocused || forceFocusedState
    }

    private var backgroundColor: Color {
        if hasUnsavedChanges?() ?? false {
            Color(uiColor: Constants.focusedTextBorderColor).opacity(0.1)
        } else if shouldShowFocusedStyle {
            .clear
        } else {
            Color(uiColor: Constants.textBackgroundColor)
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
    VStack {
        StatefulTextField(
            isLarge: false,
            fieldIdentifier: "name",
            value: .constant("value"),
            accessibilityLabel: "Accessibility Label",
            hasUnsavedChanges: { false }
        )

        StatefulTextField(
            isLarge: false,
            fieldIdentifier: "name",
            value: .constant("value"),
            accessibilityLabel: "Accessibility Label",
            hasUnsavedChanges: { false }
        )
        .disabled(true)

        StatefulTextField(
            isLarge: false,
            fieldIdentifier: "name",
            placeholder: "This is a placeholder",
            value: .constant(""),
            accessibilityLabel: "Accessibility Label",
            hasUnsavedChanges: { false }
        )

        StatefulTextField(
            isLarge: true,
            fieldIdentifier: "name",
            value: .constant("value"),
            accessibilityLabel: "Accessibility Label",
            hasUnsavedChanges: { false }
        )
    }.padding()
}
