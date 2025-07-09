import SwiftUI

extension View {
    func scrollOffsetReader(_ offset: Binding<CGFloat>) -> some View {
        if #available(iOS 18.0, *) {
            return self.onScrollGeometryChange(for: CGFloat.self, of: { geometry in
                geometry.contentOffset.y + geometry.contentInsets.top
            }, action: { _, newValue in
                offset.wrappedValue = newValue
            })
        } else {
            return self
        }
    }

    func borders(colorScheme: ColorScheme) -> some View {
        self.shape(
            RoundedRectangle(cornerRadius: 2),
            borderColor: Color(uiColor: .label).opacity(colorScheme == .dark ? 0.30 : 0.15),
            borderWidth: 1
        )
    }

    func styleTextField(colorScheme: ColorScheme) -> some View {
        self
            .font(.subheadline)
            .padding(.DS.Padding.split)
            .borders(colorScheme: colorScheme)
    }

    @ViewBuilder
    func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
