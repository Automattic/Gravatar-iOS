import SwiftUI

struct SimpleMessageView: View {
    private enum Constants {
        static let backgroundLight: UIColor = .label
        static let backgroundDark: UIColor = .rgba(225, 225, 225)
    }

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    private(set) var message: String

    var body: some View {
        Text(message)
            .font(.footnote)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, .DS.Padding.double)
            .padding(.vertical, .DS.Padding.split)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(8)
    }

    var backgroundColor: Color {
        colorScheme == .dark ? Color(uiColor: Constants.backgroundDark) : Color(uiColor: Constants.backgroundLight)
    }

    var foregroundColor: Color {
        Color(UIColor.systemBackground)
    }
}

#Preview {
    SimpleMessageView(message: "This is a long long long long long long long long long message")

    SimpleMessageView(message: "This is a short message")
}
