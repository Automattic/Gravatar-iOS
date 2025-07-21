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
                if value.isEmpty {
                    Text("- \(Localized.noData) -")
                        .font(.subheadline)
                        .italic()
                        .foregroundStyle(.secondary)
                } else {
                    Text(value)
                }
            }
            .opacity(isEnabled ? 1 : 0.5)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    ShareField(title: "Public email", value: "some@email.com", selected: .constant(false))
        .padding()
    ShareField(title: "Public email", value: "", selected: .constant(false))
        .padding()
}

private enum Localized {
    static let noData = NSLocalizedString(
        "Share.Field.noData",
        value: "No data",
        comment: "Message shown when there is no data to show in a share field")
}
