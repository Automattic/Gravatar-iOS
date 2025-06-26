import Gravatar
import SwiftUI

struct CollapsableHeaderScrollView<Content: View>: UIViewControllerRepresentable {
    let headerContentView: CollapsableHeaderViewContentType
    let scrollableContent: MultiPlatformContent<Content>
    let headerMaxHeight: CGFloat
    let headerMinHeight: CGFloat

    init(
        headerContentView: CollapsableHeaderViewContentType,
        scrollableContent: MultiPlatformContent<Content>,
        headerMaxHeight: CGFloat,
        headerMinHeight: CGFloat
    ) {
        self.headerContentView = headerContentView
        self.scrollableContent = scrollableContent
        self.headerMaxHeight = headerMaxHeight
        self.headerMinHeight = headerMinHeight
    }

    func makeUIViewController(context: Context) -> CollapsableHeaderViewController<Content> {
        CollapsableHeaderViewController(
            headerContentView: headerContentView,
            scrollableContent: scrollableContent,
            headerMaxHeight: headerMaxHeight,
            headerMinHeight: headerMinHeight
        )
    }

    func updateUIViewController(_: CollapsableHeaderViewController<Content>, context: Context) {}
}
