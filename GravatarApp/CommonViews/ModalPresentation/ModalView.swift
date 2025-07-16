import SwiftUI

struct ModalView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    @State var contentHeight: CGFloat = 0

    var body: some View {
        ScrollView {
            content()
                .contentHeightReader($contentHeight)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(.regularMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(radius: 12, x: 0, y: 8)
        .frame(maxWidth: 500, maxHeight: contentHeight)
    }
}
