import UIKit

// TODO: Replace with real implementation. This is created for demonstration purposes.
class ProfileHeaderContentView: UIView, CollapsableHeaderViewContent {
    enum Constants {
        static let avatarSizeMin: CGFloat = 60
        static let avatarSizeMax: CGFloat = 120
        static let backgroundColorExpanded = UIColor(red: 50 / 255.0, green: 160 / 255.0, blue: 168 / 255.0, alpha: 1.0)
        static let backgroundColorCollapsed = UIColor(red: 50 / 255.0, green: 168 / 255.0, blue: 54 / 255.0, alpha: 1.0)
    }

    private lazy var avatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .cyan
        imageView.image = UIImage(systemName: "person.circle")
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "John Doe"
        return label
    }()

    private lazy var organisationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.text = "Software Engineer, Automattic"
        return label
    }()

    private var expandedConstraints: [NSLayoutConstraint] = []
    private var collapsedConstraints: [NSLayoutConstraint] = []

    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubview(avatarView)
        addSubview(nameLabel)
        addSubview(organisationLabel)
        initConstraints()
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
        nameLabel.textAlignment = .center
        organisationLabel.textAlignment = .center
        self.backgroundColor = Constants.backgroundColorExpanded
    }

    private func activateCollapsedState() {
        NSLayoutConstraint.deactivate(expandedConstraints)
        NSLayoutConstraint.activate(collapsedConstraints)
        nameLabel.textAlignment = .left
        organisationLabel.textAlignment = .left
        self.backgroundColor = Constants.backgroundColorCollapsed
    }

    // MARK: Define layout constraints

    private func initConstraints() {
        collapsedConstraints = [
            avatarView.heightAnchor.constraint(equalToConstant: Constants.avatarSizeMin),
            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSizeMin),
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            avatarView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: 4),
            organisationLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            organisationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            organisationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
        ]
        expandedConstraints = [
            avatarView.heightAnchor.constraint(equalToConstant: Constants.avatarSizeMax),
            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSizeMax),
            avatarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarView.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 12),
            nameLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: 16),
            organisationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            organisationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            organisationLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: 16),
        ]
    }
}
