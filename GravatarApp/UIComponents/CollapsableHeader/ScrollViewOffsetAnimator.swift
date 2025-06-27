import UIKit

@MainActor
class ScrollViewOffsetAnimator {
    private let scrollView: UIScrollView

    private var displayLink: CADisplayLink?

    private var startOffset: CGPoint = .zero
    private var targetOffset: CGFloat = 0
    private var animationStartTime: CFTimeInterval = 0
    private var response: CGFloat = 0.4

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
    }

    func animate(to offset: CGFloat) {
        startOffset = scrollView.contentOffset
        targetOffset = offset
        animationStartTime = CACurrentMediaTime()

        calculateResponse()

        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .common)
    }

    func calculateResponse() {
        if startOffset.y > targetOffset {
            let ratio = abs(1 - (targetOffset / startOffset.y))
            response = min(0.1 * ratio, 0.05)
        } else {
            let ratio = abs(1 - (startOffset.y / targetOffset))
            response = min(0.1 * ratio, 0.05)
        }
    }

    // Triggered on every frame for as lnog as `displayLink` is active.
    @objc
    private func updateAnimation() {
        let elapsed = CACurrentMediaTime() - animationStartTime

        let progress = criticallyDampedSpring(progress: elapsed, response: response)

        let newX = startOffset.x
        let newY = interpolate(from: startOffset.y, to: targetOffset, progress: progress)

        scrollView.contentOffset = CGPoint(x: newX, y: newY)

        if progress >= 1 {
            displayLink?.invalidate()
            displayLink = nil
        }
    }

    private func interpolate(from: CGFloat, to: CGFloat, progress: Double) -> CGFloat {
        from + (to - from) * CGFloat(progress)
    }

    // Smooth spring curve without bouncing (damping = 1)
    // The duration of the animation depends on the response value. The higher it is, the softer the curve, and longer the animation.
    func criticallyDampedSpring(progress t: Double, response: Double = 0.05) -> Double {
        let damping = 1.0
        let beta = damping / (2 * response)

        let dampedValue = 1 - exp(-beta * t) * (1 + beta * t)

        return dampedValue > 0.999 ? 1 : dampedValue
    }
}
