import SwiftUI

struct ShareField: View {
    @Environment(\.isEnabled) var isEnabled

    let title: String
    let value: String

    @Binding var selected: Bool

    var body: some View {
        Toggle(isOn: $selected) {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
            }
            .opacity(isEnabled ? 1 : 0.5)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    ShareField(title: "Public email", value: "some@email.com", selected: .constant(false))
        .padding()
}
