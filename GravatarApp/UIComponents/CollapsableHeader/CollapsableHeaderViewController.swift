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

    /*
     init(headerContentView: CollapsableHeaderViewContentType,
          swiftUIContentView: ScrollContent,
          headerMaxHeight: CGFloat,
          headerMinHeight: CGFloat
     ) {
         self.headerContentView = headerContentView
         self.scrollableContent = .swiftUI(swiftUIContentView)
         self.headerMaxHeight = headerMaxHeight
         self.headerMinHeight = headerMinHeight
         super.init(nibName: nil, bundle: nil)
     }

     init(
         headerContentView: CollapsableHeaderViewContentType,
         contentView: UIView,
         headerMaxHeight: CGFloat,
         headerMinHeight: CGFloat
     ) {
         self.headerContentView = headerContentView
         self.scrollableContent = .uiView(contentView)
         self.headerMaxHeight = headerMaxHeight
         self.headerMinHeight = headerMinHeight
         super.init(nibName: nil, bundle: nil)
     }
     */
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
        return scrollView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
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

    private func setupViews() {
        view.addSubview(headerView)
        view.addSubview(scrollView)

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
        scrollView.addSubview(contentView)

        headerHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: headerMaxHeight)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerHeightConstraint,
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        headerView.setHeightConstraint(headerHeightConstraint)
    }

    // MARK: - Internal methods

    func toBeChangedOffsetY(from scrollView: UIScrollView) -> CGFloat {
        scrollView.contentOffset.y
    }

    func toBeChangedProgress(from scrollView: UIScrollView) -> CGFloat {
        toBeChangedOffsetY(from: scrollView) / (headerView.maxHeight - headerView.minHeight)
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
        let progress = toBeChangedProgress(from: scrollView)
        // print("scrollView.contentOffset.y: \(scrollView.contentOffset.y), progress: \(progress)")
        headerView.setProgress(progress)
        headerView.setNeedsLayout()
    }

    func scrollViewWillBeginDragging(_: UIScrollView) {}

    private func snap() {
        guard !currentlySnapping && headerView.progress >= 0 else { return }

        currentlySnapping = true

        if headerView.lastSnappoint == .fullHeight {
            if headerView.progress > 0.8 {
                snap(to: 1)
            } else {
                snap(to: 0)
            }
        } else if headerView.lastSnappoint == .minHeight {
            if headerView.progress < 0.2 {
                snap(to: 0)
            } else {
                snap(to: 1)
            }
        }
    }

    private func snap(to progress: CGFloat) {
        defer {
            currentlySnapping = false
        }

        let deltaProgress = progress - headerView.progress
        let deltaOffsetY = (headerView.maxHeight - headerView.minHeight) * deltaProgress
        scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + deltaOffsetY)

        self.headerView.snap(with: progress)
    }
}
