import SwiftUI

extension View {
    func contentHeightReader(_ height: Binding<CGFloat>) -> some View {
        self.onGeometryChange(for: CGSize.self) { geometry in
            geometry.size
        } action: { newValue in
            height.wrappedValue = newValue.height
        }
    }

    func contentWidthtReader(_ width: Binding<CGFloat>) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear.onChange(of: geo.size) { _, value in
                    width.wrappedValue = value.width
                }.onAppear {
                    width.wrappedValue = geo.size.width
                }
            }
        )
    }

    func borders(colorScheme: ColorScheme) -> some View {
        self.shape(
            RoundedRectangle(cornerRadius: 2),
            borderColor: Color(uiColor: .label).opacity(colorScheme == .dark ? 0.30 : 0.15),
            borderWidth: 1
        )
    }

    @ViewBuilder
    func `if`(_ condition: Bool, @ViewBuilder transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<T>(_ condition: T?, transform: (Self, T) -> some View) -> some View {
        if let condition {
            transform(self, condition)
        } else {
            self
        }
    }

    func styleTextField(colorScheme: ColorScheme) -> some View {
        self
            .font(.subheadline)
            .padding(.DS.Padding.split)
            .borders(colorScheme: colorScheme)
    }

    func addToastContainer(manager: ToastManager) -> some View {
        self.overlay {
            ToastContainerView(toastManager: manager)
        }
    }

    func avatarSytle(_ shape: some Shape) -> some View {
        self.clipShape(shape)
            .shadow(radius: 2, x: 0, y: 3)
            .overlay {
                shape.stroke(.black.opacity(0.2), lineWidth: 2)
            }
    }
}
