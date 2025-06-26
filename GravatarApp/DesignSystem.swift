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
        static let bluishColor = Color(uiColor: UIColor(red: 0.11, green: 0.31, blue: 0.77, alpha: 1.00))
    }
}
