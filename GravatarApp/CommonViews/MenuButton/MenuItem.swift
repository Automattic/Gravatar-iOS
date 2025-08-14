import UIKit

@MainActor
struct MenuItem {
    let title: String
    let systemImage: String?
    let attributes: UIMenuElement.Attributes
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, attributes: UIMenuElement.Attributes = [], action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.attributes = attributes
        self.action = action
    }
}
