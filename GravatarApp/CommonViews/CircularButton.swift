import SwiftUI

struct CircularButton: View {
    let offset: CGSize
    let action: () -> Void
    let image: () -> Image

    init(offsetX: CGFloat = 0, offsetY: CGFloat = 0, action: @escaping () -> Void, image: @escaping () -> Image) {
        self.action = action
        self.image = image
        self.offset = CGSize(width: offsetX, height: offsetY)
    }

    var body: some View {
        Button(action: {
            action()
        }) {
            image()
                .foregroundColor(Color.white)
                .frame(width: 24, height: 24)
                .padding()
                .offset(offset)
        }
        .frame(width: 44, height: 44)
        .background(Color.black.opacity(0.2))
        .clipShape(Circle())
    }
}

#Preview {
    VStack {
        CircularButton(offsetY: -2) {} image: {
            Image(systemName: "square.and.arrow.up")
        }
        CircularButton(offsetY: -2) {} image: {
            Image(systemName: "square.and.arrow.down")
        }
        CircularButton {} image: {
            Image(systemName: "cloud.heavyrain")
        }
    }
}
