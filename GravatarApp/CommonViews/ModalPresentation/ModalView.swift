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
        // Render background on snapshot tests
        .if(ProcessInfo.processInfo.isSnapshotTesting) { view in
            view.background(
                Color(uiColor: .secondarySystemBackground)
            )
        }
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(radius: 12, x: 0, y: 8)
        .frame(maxWidth: 500, maxHeight: contentHeight)
    }
}

#Preview {
    ZStack {
        Color(uiColor: .quaternaryLabel).ignoresSafeArea()
        ModalView(content: {
            VStack {
                Text("Hello, World!")
                    .font(.largeTitle)
                Text("Hello, World!")
                    .font(.largeTitle)
            }
            .padding()
        })
    }
}
