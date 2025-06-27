import Gravatar
import SwiftUI

struct CollapsableHeaderScrollView<Content: View>: UIViewControllerRepresentable {
    let headerContentView: CollapsableHeaderViewContentType
    let scrollableContent: MultiPlatformContent<Content>

    init(
        headerContentView: CollapsableHeaderViewContentType,
        scrollableContent: MultiPlatformContent<Content>,
    ) {
        self.headerContentView = headerContentView
        self.scrollableContent = scrollableContent
    }

    func makeUIViewController(context: Context) -> CollapsableHeaderViewController<Content> {
        CollapsableHeaderViewController(
            headerContentView: headerContentView,
            scrollableContent: scrollableContent
        )
    }

    func updateUIViewController(_: CollapsableHeaderViewController<Content>, context: Context) {}
}
