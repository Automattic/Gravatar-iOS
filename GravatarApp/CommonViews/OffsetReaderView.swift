import SwiftUI

/// Use this view as the first view inside the scroll view you want to get the offset from
struct OffsetReaderView: View {
    @Binding var scrollOffset: CGFloat

    var body: some View {
        GeometryReader { geo in
            Color.clear
                .onChange(of: geo.frame(in: .global).minY) { _, value in
                    scrollOffset = value
                }
        }
        .frame(height: 0)
    }
}
