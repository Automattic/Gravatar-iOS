import SwiftUI

struct ShareField: View {
    let title: String

    @Binding var value: String
    @Binding var selected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Public email")
                Toggle(isOn: $selected) { StyledTextField(value: $value, disabled: .constant(true)) }
            }
        }
    }
}
