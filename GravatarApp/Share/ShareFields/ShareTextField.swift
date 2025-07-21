import SwiftUI

struct ShareTextField: View {
    @Binding var text: String
    @Binding var selected: Bool

    let placeholder: String?

    init(text: Binding<String>, placeholder: String? = nil, selected: Binding<Bool>) {
        self._text = text
        self._selected = selected
        self.placeholder = placeholder
    }

    var body: some View {
        Toggle(isOn: $selected) {
            StatefulTextField(
                fieldIdentifier: "",
                placeholder: placeholder,
                value: $text
            )
        }
    }
}

#Preview {
    ShareTextField(text: .constant("some@email.com"), selected: .constant(true))
        .padding()
}
