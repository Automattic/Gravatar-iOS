import Combine
import GravatarUI
import UIKit

class ProfileHeaderContentView: UIView, CollapsableHeaderViewContent {
    enum Constants {
        static let backgroundColorExpanded = UIColor.clear
        static let backgroundColorCollapsed = UIColor.systemBackground
    }

    var profile: Profile? {
        didSet {
            updateProfileData()
        }
    }

    weak var delegate: (any CollapsableHeaderViewContentDelegate)?

    private let userSession: UserSession
    private var cancellables = Set<AnyCancellable>()
    private let avatarView: CircularAvatarImageView = {
        let imageView = CircularAvatarImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let nameLabelExpanded: UILabel = makeLabel(with: .nameLabelFont)
    private let nameLabelCollapsed: UILabel = makeLabel(with: .nameLabelFont)

    private let organisationLabelExpanded: UILabel = makeLabel(with: .organisationLabelFont, textColor: .secondaryLabel)
    private let organisationLabelCollapsed: UILabel = makeLabel(with: .organisationLabelFont, textColor: .secondaryLabel)

    private let locationLabel: UILabel = makeLabel(with: .locationLabelFont, textColor: .secondaryLabel)

    private let profileButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tertiarySystemFill
        config.image = UIImage(systemName: "safari")
        config.imagePlacement = .leading
        config.imagePadding = 4
        config.baseForegroundColor = .systemBlue
        config.cornerStyle = .capsule

        let button = UIButton(configuration: config, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    static func makeLabel(with font: UIFont, textColor: UIColor = .label) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = font
        label.textColor = textColor
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    lazy var allViews: [UIView] = [
        avatarView,
        nameLabelExpanded,
        nameLabelCollapsed,
        organisationLabelExpanded,
        organisationLabelCollapsed,
        locationLabel,
        profileButton,
    ]

    private var expandedConstraints: [NSLayoutConstraint] = []
    private var collapsedConstraints: [NSLayoutConstraint] = []

    required init(userSession: UserSession = .shared) {
        self.userSession = userSession
        self.profile = userSession.profile

        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false

        for view in allViews {
            addSubview(view)
        }

        initConstraints()
        updateProfileData()
        userSession.$profile.sink { [weak self] profile in
            guard let self else { return }
            self.profile = profile
            // Recreate the animator otherwise text alignments get messed up
            self.delegate?.didUpdateData(self)
        }
        .store(in: &cancellables)
    }

    func makeCopy() -> Self {
        .init(userSession: userSession)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: CollapsableHeaderViewContent

    func updateUI(for snappoint: CollapsableHeaderSnappoint) {
        switch snappoint {
        case .fullHeight:
            activateExpandedState()
        case .minHeight:
            activateCollapsedState()
        }
    }

    func interpolate(with progress: CGFloat) {
        // Make label and button disappear faster to avoid too much overlaping
        locationLabel.alpha = 1 - progress * 2
        profileButton.alpha = 1 - progress * 2
    }

    // MARK: Activate different states

    private func activateExpandedState() {
        NSLayoutConstraint.deactivate(collapsedConstraints)
        NSLayoutConstraint.activate(expandedConstraints)

        setAlphas(collapsed: false)
        setLabelsNeedDisplay()

        avatarView.shadowView.layer.shadowColor = UIColor.black.cgColor
        backgroundColor = Constants.backgroundColorExpanded
    }

    private func activateCollapsedState() {
        NSLayoutConstraint.deactivate(expandedConstraints)
        NSLayoutConstraint.activate(collapsedConstraints)

        setAlphas(collapsed: true)
        setLabelsNeedDisplay()

        avatarView.shadowView.layer.shadowColor = UIColor.clear.cgColor
        backgroundColor = Constants.backgroundColorCollapsed
    }

    private func setLabelsNeedDisplay() {
        organisationLabelCollapsed.setNeedsDisplay()
        organisationLabelExpanded.setNeedsDisplay()
        nameLabelCollapsed.setNeedsDisplay()
        nameLabelExpanded.setNeedsDisplay()
    }

    private func setAlphas(collapsed: Bool) {
        organisationLabelCollapsed.alpha = collapsed ? 1 : 0
        organisationLabelExpanded.alpha = collapsed ? 0 : 1
        nameLabelCollapsed.alpha = collapsed ? 1 : 0
        nameLabelExpanded.alpha = collapsed ? 0 : 1
    }

    private func updateProfileData() {
        guard let profile else { return }
        nameLabelExpanded.text = profile.displayName
        nameLabelCollapsed.text = profile.displayName
        organisationLabelExpanded.text = "\(profile.jobTitle), \(profile.company)"
        organisationLabelCollapsed.text = "\(profile.jobTitle), \(profile.company)"
        locationLabel.text = profile.location

        var config = profileButton.configuration
        config?.title = profile.profileUrl.replacingOccurrences(of: "https://", with: "")
        profileButton.configuration = config

        Task {
            try await avatarView.imageView.gravatar.setImage(avatarID: .hashID(profile.hash))
        }
    }

    // MARK: Define layout constraints

    private func initConstraints() {
        collapsedConstraints = [
            avatarView.heightAnchor.constraint(equalToConstant: .avatarSizeMin),
            avatarView.widthAnchor.constraint(equalToConstant: .avatarSizeMin),

            avatarView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .hPadding),

            nameLabelExpanded.topAnchor.constraint(equalTo: avatarView.topAnchor),
            nameLabelExpanded.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: .avatarHSpace),
            nameLabelExpanded.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -.hPadding),

            nameLabelCollapsed.topAnchor.constraint(equalTo: avatarView.topAnchor),
            nameLabelCollapsed.leadingAnchor.constraint(equalTo: nameLabelExpanded.leadingAnchor),
            nameLabelCollapsed.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -.hPadding),

            organisationLabelExpanded.topAnchor.constraint(equalTo: nameLabelExpanded.bottomAnchor),
            organisationLabelExpanded.leadingAnchor.constraint(equalTo: nameLabelExpanded.leadingAnchor),
            organisationLabelExpanded.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -.hPadding),
            organisationLabelExpanded.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.hPadding),

            organisationLabelCollapsed.topAnchor.constraint(equalTo: nameLabelExpanded.bottomAnchor),
            organisationLabelCollapsed.leadingAnchor.constraint(equalTo: nameLabelExpanded.leadingAnchor),
            organisationLabelCollapsed.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -.hPadding),
            organisationLabelCollapsed.bottomAnchor.constraint(equalTo: organisationLabelExpanded.bottomAnchor),

            locationLabel.bottomAnchor.constraint(equalTo: profileButton.topAnchor, constant: .hPadding),
            locationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            profileButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.hPadding),
            profileButton.centerXAnchor.constraint(equalTo: centerXAnchor),
        ]

        expandedConstraints = [
            avatarView.heightAnchor.constraint(equalToConstant: .avatarSizeMax),
            avatarView.widthAnchor.constraint(equalToConstant: .avatarSizeMax),

            avatarView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            avatarView.centerXAnchor.constraint(equalTo: centerXAnchor),

            nameLabelExpanded.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: .hPadding),
            nameLabelExpanded.centerXAnchor.constraint(equalTo: centerXAnchor),
            nameLabelExpanded.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -.hPadding),

            nameLabelCollapsed.topAnchor.constraint(equalTo: nameLabelExpanded.topAnchor),
            nameLabelCollapsed.leadingAnchor.constraint(equalTo: nameLabelExpanded.leadingAnchor),

            organisationLabelExpanded.topAnchor.constraint(equalTo: nameLabelExpanded.bottomAnchor, constant: .vPadding),
            organisationLabelExpanded.centerXAnchor.constraint(equalTo: centerXAnchor),
            organisationLabelExpanded.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -.hPadding),

            organisationLabelCollapsed.topAnchor.constraint(equalTo: organisationLabelExpanded.topAnchor),
            organisationLabelCollapsed.leadingAnchor.constraint(equalTo: organisationLabelExpanded.leadingAnchor),

            locationLabel.topAnchor.constraint(equalTo: organisationLabelExpanded.bottomAnchor, constant: .vPadding),
            locationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            locationLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -.hPadding),

            profileButton.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: .hPadding),
            profileButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.hPadding),
        ]
    }
}

#if DEBUG
#Preview("Max height") {
    let userSession = UserSession()
    userSession.updateProfile(.testProfile)
    let view = ProfileHeaderContentView(userSession: userSession)
    view.updateUI(for: .fullHeight)
    view.interpolate(with: 0)
    return view
}

#Preview("Min height") {
    let userSession = UserSession()
    userSession.updateProfile(.testProfile)
    let view = ProfileHeaderContentView(userSession: userSession)
    view.updateUI(for: .minHeight)
    view.interpolate(with: 1)
    return view
}
#endif

extension UIFont {
    fileprivate static let nameLabelFont: UIFont = .preferredFont(forTextStyle: .title3).with(weight: .semibold)
    fileprivate static let organisationLabelFont: UIFont = .preferredFont(forTextStyle: .headline)
    fileprivate static let locationLabelFont: UIFont = .preferredFont(forTextStyle: .headline)
}

extension CGFloat {
    fileprivate static let avatarSizeMin: CGFloat = 44
    fileprivate static let avatarSizeMax: CGFloat = 105
    fileprivate static let hPadding: CGFloat = 16
    fileprivate static let vPadding: CGFloat = 8
    fileprivate static let avatarHSpace: CGFloat = 14
}

extension UIFont {
    func with(weight: UIFont.Weight) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes(
            [.traits: [UIFontDescriptor.TraitKey.weight: weight]]
        )
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}
