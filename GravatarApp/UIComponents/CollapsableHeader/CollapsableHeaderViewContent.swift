import Foundation

enum CollapsableHeaderSnappoint: CGFloat, Sendable {
    case fullHeight = 1.0
    case minHeight = 0.0
}

@MainActor
protocol CollapsableHeaderViewContent {
    func updateUI(for snappoint: CollapsableHeaderSnappoint)
    func interpolate(with progress: CGFloat)
}
