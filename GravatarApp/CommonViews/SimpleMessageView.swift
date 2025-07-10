import SwiftUI

struct SimpleMessageView: View {
    private enum Constants {
        static let backgroundColor = UIColor(light: .label, dark: .rgba(225, 225, 225))
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
        Color(Constants.backgroundColor)
    }

    var foregroundColor: Color {
        Color(UIColor.systemBackground)
    }
}

#Preview {
    SimpleMessageView(message: "This is a long long long long long long long long long message")

    SimpleMessageView(message: "This is a short message")
}
