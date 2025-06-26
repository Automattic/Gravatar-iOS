import Foundation

enum CollapsableHeaderSnappoint: CGFloat, Sendable {
    case fullHeight = 1.0
    case minHeight = 0.0
}

@MainActor
protocol CollapsableHeaderViewContent {
    /// Implement different UI states for each snappoint. Transition between these UI states will be animated by `UIViewPropertyAnimator`.
    func updateUI(for snappoint: CollapsableHeaderSnappoint)

    /// Implement this method for any interpolations not supported by `UIViewPropertyAnimator`.
    func interpolate(with progress: CGFloat)
}
