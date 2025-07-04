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
}
