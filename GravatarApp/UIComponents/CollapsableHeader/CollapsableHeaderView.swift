import UIKit

class CollapsableHeaderView: UIView {
    enum Constants {
        static let fullAnimationDuration: TimeInterval = 0.3
        static let snapAnimationDuration: TimeInterval = 0.15
    }

    private(set) var maxHeight: CGFloat {
        get { _maxHeight }
        set { _maxHeight = fmax(newValue, 0.0) }
    }

    private(set) var minHeight: CGFloat {
        get { _minHeight }
        set { _minHeight = fmax(newValue, 0.0) }
    }

    private(set) var progress: CGFloat {
        get { _progress }
        set {
            _progress = fmax(fmin(newValue, 1.0), 0.0)
            if _progress == 1.0 {
                lastSnappoint = .minHeight
            } else if _progress == 0.0 {
                lastSnappoint = .fullHeight
            }
        }
    }

    private(set) var contentView: CollapsableHeaderViewContent
    private(set) var lastSnappoint: CollapsableHeaderSnappoint = .fullHeight
    private var _maxHeight: CGFloat = 0.0
    private var _minHeight: CGFloat = 0.0
    private var _progress: CGFloat = 0.0
    private var animator: UIViewPropertyAnimator?
    private var lastWidth: CGFloat = 0

    init(contentView: CollapsableHeaderViewContent) {
        self.contentView = contentView
        super.init(frame: .zero)

        addSubview(contentView)
        setupContent()
        self.lastSnappoint = .fullHeight
    }

    private func setupContent() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    func initAnimator(with progress: CGFloat? = nil) {
        // reset the UI

        contentView.updateUI(for: .fullHeight)

        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()

        // init the animator in the next run loop so UI state starts from .fullHeight
        Task { @MainActor [weak self] in
            guard let self else { return }
            let newAnimator = UIViewPropertyAnimator(duration: Constants.fullAnimationDuration, curve: .linear) { [weak self] in
                guard let self else { return }

                contentView.updateUI(for: .minHeight)

                superview?.layoutIfNeeded()
            }
            newAnimator.pauseAnimation()
            if let progress {
                // set the progress if given
                newAnimator.fractionComplete = progress
            }
            animator = newAnimator
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        let currentWidth = bounds.width
        if currentWidth != lastWidth {
            if lastWidth != 0 {
                print("Width changed to: \(currentWidth)")
                handleWidthChange()
            }
            lastWidth = currentWidth
        }
    }

    @objc
    func calculateHeight() {
        let copyContentView = contentView.makeCopy()
        let widthConstaint = copyContentView.widthAnchor.constraint(equalToConstant: frame.width)
        widthConstaint.isActive = true

        copyContentView.updateUI(for: .minHeight)
        copyContentView.setNeedsLayout()
        copyContentView.layoutIfNeeded()
        _minHeight = copyContentView.bounds.height

        copyContentView.updateUI(for: .fullHeight)
        copyContentView.setNeedsLayout()
        copyContentView.layoutIfNeeded()
        _maxHeight = copyContentView.bounds.height
    }

    private func handleWidthChange() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.stopAndResetAnimator(with: self.progress)
        }
    }

    private func interpolate(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
        from - ((from - to) * progress)
    }

    func setProgress(_ newProgress: CGFloat) {
        guard let animator else {
            return
        }
        self.progress = fmin(fmax(newProgress, 0.0), 1.0)
        animator.fractionComplete = progress
        self.contentView.interpolate(with: progress)
    }

    func stopAndResetAnimator(with progress: CGFloat) {
        guard let animator else {
            return
        }
        if animator.state != .stopped && animator.isInterruptible {
            animator.stopAnimation(false)
            animator.addCompletion { [weak self] _ in
                guard let self else { return }
                self.initAnimator(with: progress)
            }
            animator.finishAnimation(at: .current)
        }
    }

    func cleanupAnimator() {
        self.animator?.stopAnimation(false)
        self.animator?.finishAnimation(at: .current)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
