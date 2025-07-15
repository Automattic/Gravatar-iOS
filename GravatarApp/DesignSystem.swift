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

extension Color {
    enum DS {
        static let bluishColor = Color(uiColor: UIColor(
            light: UIColor(red: 0.11, green: 0.31, blue: 0.77, alpha: 1.00),
            dark: UIColor(red: 0.34, green: 0.52, blue: 0.93, alpha: 1.00)
        ))
    }
}

struct ActionButtonStyle: ButtonStyle {
    enum Style {
        case primary
        case secondary
    }

    let style: Style

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(style == .primary ? Color.primary : Color(uiColor: .quaternaryLabel))
            .foregroundStyle(style == .primary ? Color(uiColor: .systemBackground) : Color.primary)
            .clipShape(.capsule)
    }
}

extension ButtonStyle where Self == ActionButtonStyle {
    static func actionButton(style: ActionButtonStyle.Style = .primary) -> ActionButtonStyle {
        ActionButtonStyle(style: style)
    }
}
