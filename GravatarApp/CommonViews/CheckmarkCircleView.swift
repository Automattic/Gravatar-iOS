import SwiftUI

private enum Constants {
    static let circleSize: CGFloat = 20
    static let checkmarkImageSize: CGFloat = 10
}

struct CheckmarkCircleView: View {
    @State private var scale: CGFloat = 0.0

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.DS.bluishColor)
                .frame(width: Constants.circleSize, height: Constants.circleSize)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                )
                .environment(\.colorScheme, .light)

            Image(systemName: "checkmark")
                .foregroundColor(.white)
                .font(.system(size: Constants.checkmarkImageSize, weight: .medium))
        }
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(.bouncy(extraBounce: 0.1))) {
                scale = 1.0
            }
        }
    }
}

#Preview {
    GeometryReader { geometry in
        VStack {
            CheckmarkCircleView()
        }
        .frame(
            width: geometry.size.width,
            height: geometry.size.height
        )
    }.background(Color.secondary)
}
