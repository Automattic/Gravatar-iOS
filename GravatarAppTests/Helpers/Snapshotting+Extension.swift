import SnapshotTesting
import SwiftUI
import XCTest

extension Snapshotting where Value: SwiftUI.View, Format == UIImage {
    static func testStrategy(userInterfaceStyle: UIUserInterfaceStyle = .light, layout: SwiftUISnapshotLayout = .sizeThatFits) -> Self {
        let deviceConfig: ViewImageConfig = .iPhone13
        let traits = UITraitCollection().modifyingTraits { mutableTraits in
            mutableTraits.userInterfaceStyle = userInterfaceStyle
            mutableTraits.displayScale = deviceConfig.traits.displayScale
        }

        return .image(
            layout: layout,
            traits: traits
        )
    }
}
