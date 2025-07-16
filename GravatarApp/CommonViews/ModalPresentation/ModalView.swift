import SwiftUI

struct ModalView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    @State var contentHeight: CGFloat = 0
    @Environment(\.modalBackground) private var modalBackground

    var body: some View {
        ScrollView {
            content()
                .contentHeightReader($contentHeight)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(modalBackground)
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(radius: 12, x: 0, y: 8)
        .frame(maxWidth: 500, maxHeight: contentHeight)
    }
}

private struct ModalBackgroundKey: EnvironmentKey {
    static let defaultValue: AnyShapeStyle = .init(.regularMaterial)
}

extension EnvironmentValues {
    var modalBackground: AnyShapeStyle {
        get { self[ModalBackgroundKey.self] }
        set { self[ModalBackgroundKey.self] = newValue }
    }
}

extension View {
    func modalBackground(_ style: some ShapeStyle) -> some View {
        environment(\.modalBackground, AnyShapeStyle(style))
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
