import SwiftUI

struct EllipsisButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: "ellipsis")
                .foregroundColor(Color.white)
                .frame(width: 24, height: 24)
                .padding()
        }
        .frame(width: 40, height: 40)
        .background(Color.black.opacity(0.2))
        .clipShape(Circle())
    }
}

struct EllipsisButton_Previews: PreviewProvider {
    static var previews: some View {
        EllipsisButton(action: {})
    }
}
