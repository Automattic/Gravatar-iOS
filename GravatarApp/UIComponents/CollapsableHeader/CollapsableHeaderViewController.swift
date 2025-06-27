import SwiftUI
import UIKit

enum MultiPlatformContent<Content: View> {
    case swiftUI(Content)
    case uiView(UIView)
}

class CollapsableHeaderViewController<ScrollContent: View>: UIViewController, UIScrollViewDelegate {
    private let headerContentView: CollapsableHeaderViewContentType
    private let scrollableContent: MultiPlatformContent<ScrollContent>
    private let headerMaxHeight: CGFloat
    private let headerMinHeight: CGFloat
    private var headerHeightConstraint: NSLayoutConstraint = .init()
    private var currentlySnapping = false

    init(
        headerContentView: CollapsableHeaderViewContentType,
        scrollableContent: MultiPlatformContent<ScrollContent>,
        headerMaxHeight: CGFloat,
        headerMinHeight: CGFloat
    ) {
        self.headerContentView = headerContentView
        self.scrollableContent = scrollableContent
        self.headerMaxHeight = headerMaxHeight
        self.headerMinHeight = headerMinHeight
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var headerView: CollapsableHeaderView = {
        let view = CollapsableHeaderView(
            maxHeight: headerMaxHeight,
            minHeight: headerMinHeight,
            contentView: headerContentView
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerView.initAnimator(with: headerView.progress)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        headerView.cleanupAnimator()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if scrollView.contentInset.top == 0 {
            scrollView.contentInset = .init(top: headerView.bounds.height - view.safeAreaInsets.top, left: 0, bottom: 0, right: 0)

        }
    }

    private func setupViews() {
        view.addSubview(scrollView)
        view.addSubview(headerView)

        let contentView: UIView
        switch scrollableContent {
        case .swiftUI(let swiftUIView):
            let hostingController = UIHostingController(rootView: swiftUIView)
            addChild(hostingController)
            contentView = hostingController.view
            scrollView.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
        case .uiView(let view):
            contentView = view
            scrollView.addSubview(view)
        }
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        scrollView.addSubview(contentView)

        headerHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: headerMaxHeight)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerHeightConstraint,
        ])
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        headerView.setHeightConstraint(headerHeightConstraint)
    }

    // MARK: - Internal methods

    private func newProgress(from scrollView: UIScrollView) -> CGFloat {
        let offset = scrollView.contentOffset.y
        return newProgress(offset: offset)
    }

    private func newProgress(offset: CGFloat) -> CGFloat {
        let inset = scrollView.contentInset.top
        let progress = (inset + view.safeAreaInsets.top + offset) / (headerView.maxHeight - headerView.minHeight)

        return progress
    }

    func scrollViewDidEndDecelerating(_: UIScrollView) {
        snap()
    }

    func scrollViewDidEndDragging(_: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        snap()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !currentlySnapping else { return }
        let progress = newProgress(from: scrollView)
        headerView.setProgress(progress)
        headerView.setNeedsLayout()
    }

    func scrollViewWillBeginDragging(_: UIScrollView) {}

    private func snap() {
        guard !currentlySnapping && headerView.progress > 0 && headerView.progress < 1 else { return }

        currentlySnapping = true
        if headerView.lastSnappoint == .fullHeight {
            if headerView.progress > 0.2 {
                snap(to: 1)
            } else {
                snap(to: 0)
            }
        } else if headerView.lastSnappoint == .minHeight {
            if headerView.progress > 0.8 {
                snap(to: 1)
            } else {
                snap(to: 0)
            }
        }
    }

    lazy var offsetAnimator = ScrollViewOffsetAnimator(scrollView: scrollView)

    private func snap(to progress: CGFloat) {
        defer {
            currentlySnapping = false
        }

        let targetOffset  = progress * (headerView.maxHeight - headerView.minHeight) - (scrollView.contentInset.top + view.safeAreaInsets.top)
        offsetAnimator.animate(to: targetOffset, duration: 0.5)
    }
}

@MainActor
class ScrollViewOffsetAnimator {
    private let scrollView: UIScrollView

    private var displayLink: CADisplayLink?

    private var startOffset: CGPoint = .zero
    private var targetOffset: CGFloat = 0
    private var animationStartTime: CFTimeInterval = 0
    private var animationDuration: TimeInterval = 0
    private var response: CGFloat = 0.4

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
    }

    func animate(to offset: CGFloat, duration: TimeInterval) {
        startOffset = scrollView.contentOffset
        targetOffset = offset
        animationDuration = duration
        animationStartTime = CACurrentMediaTime()

        if startOffset.y > targetOffset {
            let ratio = abs(1 - (targetOffset / startOffset.y))
            response = min(0.1 * ratio, 0.05)
        } else {
            let ratio = abs(1 - (startOffset.y / targetOffset))
            response = min(0.1 * ratio, 0.05)
        }

        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateAnimation() {
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
        return from + (to - from) * CGFloat(progress)
    }

    func criticallyDampedSpring(progress t: Double, response: Double = 0.05) -> Double {
        let damping: Double = 1.0
        let beta = damping / (2 * response)

        let dampedValue = 1 - exp(-beta * t) * (1 + beta * t)
        return dampedValue > 0.999 ? 1 : dampedValue
    }
}
