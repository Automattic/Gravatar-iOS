import SwiftUI
import UIKit

enum MultiPlatformContent<Content: View> {
    case swiftUI(Content)
    case uiView(UIView)
}

class CollapsableHeaderViewController<ScrollContent: View>: UIViewController, UIScrollViewDelegate {
    private let headerContentView: CollapsableHeaderViewContent
    private let scrollableContent: MultiPlatformContent<ScrollContent>

    init(
        headerContentView: CollapsableHeaderViewContent,
        scrollableContent: MultiPlatformContent<ScrollContent>
    ) {
        self.headerContentView = headerContentView
        self.scrollableContent = scrollableContent
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var headerView: CollapsableHeaderView = {
        let view = CollapsableHeaderView(
            contentView: headerContentView
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var headerMinHeight: CGFloat {
        headerView.minHeight + view.safeAreaInsets.top
    }

    var headerMaxHeight: CGFloat {
        headerView.maxHeight + view.safeAreaInsets.top
    }

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

        registerForTraitChanges(
            [UITraitPreferredContentSizeCategory.self],
            target: self,
            action: #selector(recalculateHeightDerivedValues)
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidEnterBackgroundNotification),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    @objc
    private func handleDidEnterBackgroundNotification() {
        headerView.cleanupAnimator()
    }

    @objc
    private func handleWillEnterForeground() {
        headerView.initAnimator(with: headerView.progress)
    }

    @objc
    func recalculateHeightDerivedValues() {
        headerView.calculateHeight()
        scrollView.contentInset = .init(top: headerView.maxHeight, left: 0, bottom: 0, right: 0)
        headerView.stopAndResetAnimator(with: headerView.progress)
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
            headerView.calculateHeight()
            scrollView.contentInset = .init(top: headerView.maxHeight, left: 0, bottom: 0, right: 0)
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

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
    }

    // MARK: - Internal methods

    private func newProgress(from scrollView: UIScrollView) -> CGFloat {
        let offset = scrollView.contentOffset.y
        let inset = scrollView.contentInset.top
        let progress = (inset + view.safeAreaInsets.top + offset) / (headerMaxHeight - headerMinHeight)

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
        let progress = newProgress(from: scrollView)
        headerView.setProgress(progress)
        headerView.setNeedsLayout()
    }

    func scrollViewWillBeginDragging(_: UIScrollView) {}

    private func snap() {
        guard headerView.progress > 0 && headerView.progress < 1 else { return }

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

    private func snap(to progress: CGFloat) {
        let targetOffset = progress * (headerMaxHeight - headerMinHeight) - (scrollView.contentInset.top + view.safeAreaInsets.top)
        let offset = scrollView.contentOffset

        scrollView.setContentOffset(.init(x: offset.x, y: targetOffset), animated: true)
    }
}
