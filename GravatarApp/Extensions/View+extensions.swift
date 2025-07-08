import SwiftUI

extension View {
    func contentHeightReader(_ height: Binding<CGFloat>) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear.onChange(of: geo.size) { _, value in
                    height.wrappedValue = value.height
                }.onAppear {
                    height.wrappedValue = geo.size.height
                }
            }
        )
    }
}

extension View {
    @ViewBuilder
    func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
