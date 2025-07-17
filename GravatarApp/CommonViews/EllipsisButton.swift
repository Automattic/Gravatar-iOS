import SwiftUI

struct EllipsisButton: View {
    let action: () -> Void

    var body: some View {
        CircularButton(
            action: action,
            image: { Image(systemName: "ellipsis") }
        )
    }
}

#Preview {
    EllipsisButton(action: {})
}

