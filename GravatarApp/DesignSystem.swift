import Foundation
import SwiftUI

extension CGFloat {
    enum DS {
        enum Padding {
            public static let half: CGFloat = 4
            public static let single: CGFloat = 8
            public static let split: CGFloat = 12
            public static let double: CGFloat = 16
            public static let medium: CGFloat = 24
            public static let large: CGFloat = 32
            public static let max: CGFloat = 48
        }
    }
}

extension CGFloat {
    enum Global {
        public static let contentHorizontalPadding: CGFloat = .DS.Padding.double
        public static let contentBottomPadding: CGFloat = .DS.Padding.double
        public static let verticalSectionSpacing: CGFloat = .DS.Padding.double
        public static let verticalElementsSpacing: CGFloat = .DS.Padding.single
    }
}

extension UIColor {
    enum DS {
        static let almostWhite: UIColor = .rgba(225, 225, 225)
    }
}

extension Color {
    enum DS {
        static let bluishColor = Color(uiColor: UIColor(
            light: UIColor(red: 0.11, green: 0.31, blue: 0.77, alpha: 1.00),
            dark: UIColor(red: 0.34, green: 0.52, blue: 0.93, alpha: 1.00)
        ))
        static let oppositeBackgroundColor: Color = .init(uiColor: UIColor(light: .black, dark: .DS.almostWhite))
        static let avatarPlaceholderColor = Color(uiColor: .init(
            light: .rgba(178, 178, 186),
            dark: .rgba(68, 68, 78)
        ))
        static let backgroundOverMaterial = Color(uiColor: .init(
            light: .white,
            dark: .quaternarySystemFill.resolvedColor(with: .init(userInterfaceStyle: .dark))
        ))
    }
}

struct ActionButtonStyle: ButtonStyle {
    enum Style {
        case primary
        case secondary

        var backgroundColor: Color {
            switch self {
            case .primary:
                Color.DS.oppositeBackgroundColor
            case .secondary:
                Color(uiColor: .quaternaryLabel)
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary:
                Color(uiColor: .systemBackground)
            case .secondary:
                Color.primary
            }
        }
    }

    let style: Style

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(style.backgroundColor)
            .foregroundStyle(style.foregroundColor)
            .clipShape(.capsule)
    }
}

extension ButtonStyle where Self == ActionButtonStyle {
    static func actionButton(style: ActionButtonStyle.Style = .primary) -> ActionButtonStyle {
        ActionButtonStyle(style: style)
    }
}
