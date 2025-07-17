import SwiftUI

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
