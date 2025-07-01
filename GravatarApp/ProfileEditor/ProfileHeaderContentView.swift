import GravatarUI
import UIKit

class CircularAvatarImageView: UIView {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let shadowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.50
        view.layer.shadowRadius = 2
        return view
    }()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(shadowView)
        addSubview(imageView)
        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: topAnchor),
            shadowView.leadingAnchor.constraint(equalTo: leadingAnchor),
            shadowView.trailingAnchor.constraint(equalTo: trailingAnchor),
            shadowView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shadowView.layer.cornerRadius = bounds.width / 2.0
        imageView.layer.cornerRadius = bounds.width / 2.0
    }
}

extension UIFont {
    fileprivate static let nameLabelFont: UIFont = .preferredFont(forTextStyle: .title3).with(weight: .semibold)
    fileprivate static let organisationLabelFont: UIFont = .preferredFont(forTextStyle: .headline)
    fileprivate static let locationLabelFont: UIFont = .preferredFont(forTextStyle: .headline)
}

class ProfileHeaderContentView: UIView, CollapsableHeaderViewContent {
    enum Constants {
        static let avatarSizeMin: CGFloat = 44
        static let avatarSizeMax: CGFloat = 105
        static let backgroundColorExpanded = UIColor.clear
        static let backgroundColorCollapsed = UIColor.systemBackground
    }

    var profile: Profile {
        didSet {
            updateProfileData()
        }
    }

    private let avatarView: CircularAvatarImageView = {
        let imageView = CircularAvatarImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let nameLabel: UILabel = makeLabel(with: .nameLabelFont)
    private let nameLabelCollapsed: UILabel = makeLabel(with: .nameLabelFont)

    private let organisationLabel: UILabel = makeLabel(with: .organisationLabelFont, textColor: .secondaryLabel)
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
        nameLabel,
        nameLabelCollapsed,
        organisationLabel,
        organisationLabelCollapsed,
        locationLabel,
        profileButton,
    ]

    private var expandedConstraints: [NSLayoutConstraint] = []
    private var collapsedConstraints: [NSLayoutConstraint] = []

    init(profile: Profile) {
        self.profile = profile

        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false

        for view in allViews {
            addSubview(view)
        }

        initConstraints()
        updateProfileData()
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
        organisationLabel.setNeedsDisplay()
        nameLabelCollapsed.setNeedsDisplay()
        nameLabel.setNeedsDisplay()
    }

    private func setAlphas(collapsed: Bool) {
        organisationLabelCollapsed.alpha = collapsed ? 1 : 0
        organisationLabel.alpha = collapsed ? 0 : 1
        nameLabelCollapsed.alpha = collapsed ? 1 : 0
        nameLabel.alpha = collapsed ? 0 : 1
    }

    private func updateProfileData() {
        nameLabel.text = profile.displayName
        nameLabelCollapsed.text = profile.displayName
        organisationLabel.text = "\(profile.jobTitle), \(profile.company)"
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
            avatarView.heightAnchor.constraint(equalToConstant: Constants.avatarSizeMin),
            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSizeMin),

            avatarView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            nameLabel.topAnchor.constraint(equalTo: avatarView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 14),
            nameLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -16),

            nameLabelCollapsed.topAnchor.constraint(equalTo: avatarView.topAnchor),
            nameLabelCollapsed.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nameLabelCollapsed.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            organisationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0),
            organisationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            organisationLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -16),
            organisationLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            organisationLabelCollapsed.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            organisationLabelCollapsed.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            organisationLabelCollapsed.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            organisationLabelCollapsed.bottomAnchor.constraint(equalTo: organisationLabel.bottomAnchor),

            locationLabel.bottomAnchor.constraint(equalTo: profileButton.topAnchor, constant: 16),
            locationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            profileButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            profileButton.centerXAnchor.constraint(equalTo: centerXAnchor),
        ]

        expandedConstraints = [
            avatarView.heightAnchor.constraint(equalToConstant: Constants.avatarSizeMax),
            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSizeMax),

            avatarView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            avatarView.centerXAnchor.constraint(equalTo: centerXAnchor),

            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            nameLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -16),

            nameLabelCollapsed.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            nameLabelCollapsed.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            organisationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            organisationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            organisationLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -16),

            organisationLabelCollapsed.topAnchor.constraint(equalTo: organisationLabel.topAnchor),
            organisationLabelCollapsed.leadingAnchor.constraint(equalTo: organisationLabel.leadingAnchor),

            locationLabel.topAnchor.constraint(equalTo: organisationLabel.bottomAnchor, constant: 8),
            locationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            locationLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -16),

            profileButton.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
            profileButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ]
    }
}

#if DEBUG
#Preview {
    let view = ProfileHeaderContentView(profile: .testProfile)
    view.updateUI(for: .fullHeight)
    return view
}

#Preview("Min height") {
    let view = ProfileHeaderContentView(profile: .testProfile)
    view.updateUI(for: .minHeight)
    return view
}
#endif

extension UIFont {
    func with(weight: UIFont.Weight) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes(
            [.traits: [UIFontDescriptor.TraitKey.weight: weight]]
        )
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}
