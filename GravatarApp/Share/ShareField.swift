import SwiftUI

struct ShareField: View {
    @Environment(\.colorScheme) var colorScheme

    let title: String
    let value: String

    @Binding var selected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                Toggle(isOn: $selected) {
                    TextField("", text: .constant(value))
                        .styleTextField(colorScheme: colorScheme)
                        .disabled(true)
                }
            }
        }
    }
}

#Preview {
    ShareField(title: "Public email", value: "some@email.com", selected: .constant(false))
}
