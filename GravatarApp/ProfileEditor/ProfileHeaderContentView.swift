import UIKit
import GravatarUI

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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shadowView.layer.cornerRadius = bounds.width / 2.0
        imageView.layer.cornerRadius = bounds.width / 2.0
    }
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

    private lazy var avatarView: CircularAvatarImageView = {
        let imageView = CircularAvatarImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title3).with(weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private lazy var organisationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var profileButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tertiarySystemFill
        config.image = UIImage(systemName: "safari")
        config.imagePlacement = .leading
        config.imagePadding = 4
        config.baseForegroundColor = .systemBlue
        config.cornerStyle = .capsule
        let button = UIButton(configuration: config, primaryAction: nil)

        return button
    }()

    private lazy var rootStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            animatedStackView,
            profileButton
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        return stackView
    }()

    private lazy var animatedStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            avatarView,
            labelsStackView,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        return stackView
    }()

    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nameLabel,
            organisationLabel,
            locationLabel
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()

    private var expandedConstraints: [NSLayoutConstraint] = []
    private var collapsedConstraints: [NSLayoutConstraint] = []

    init(profile: Profile) {
        self.profile = profile

        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rootStackView)
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
        // no need
    }

    // MARK: Activate different states

    private func activateExpandedState() {
        NSLayoutConstraint.deactivate(collapsedConstraints)
        NSLayoutConstraint.activate(expandedConstraints)

        animatedStackView.axis = .vertical
        labelsStackView.alignment = .center
        rootStackView.alignment = .center
        locationLabel.isHidden = false
        locationLabel.alpha = 1
        profileButton.alpha = 1
        avatarView.shadowView.layer.shadowColor = UIColor.black.cgColor

        self.backgroundColor = Constants.backgroundColorExpanded
    }

    private func activateCollapsedState() {
        NSLayoutConstraint.deactivate(expandedConstraints)
        NSLayoutConstraint.activate(collapsedConstraints)

        animatedStackView.axis = .horizontal
        labelsStackView.alignment = .leading
        rootStackView.alignment = .leading
        locationLabel.isHidden = true
        locationLabel.alpha = 0
        profileButton.alpha = 0
        avatarView.shadowView.layer.shadowColor = UIColor.clear.cgColor

        self.backgroundColor = Constants.backgroundColorCollapsed
    }

    private func updateProfileData() {
        nameLabel.text = profile.displayName
        organisationLabel.text = "\(profile.jobTitle), \(profile.company)"
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
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant:  -16),
        ])
        collapsedConstraints = [
            avatarView.heightAnchor.constraint(equalToConstant: Constants.avatarSizeMin),
            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSizeMin),
        ]
        expandedConstraints = [
            avatarView.heightAnchor.constraint(equalToConstant: Constants.avatarSizeMax),
            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSizeMax),
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
