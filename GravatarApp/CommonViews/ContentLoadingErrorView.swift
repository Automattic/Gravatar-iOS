import SwiftUI

struct ContentLoadingErrorView: View {
    enum Constants {
        static let retryTextColor: UIColor = .init(light: .white, dark: .black)
        static let retryBackgroundColor: UIColor = .init(light: .black, dark: .rgba(225, 225, 225))
    }

    let title: String
    let description: String
    let buttonTitle: String
    let buttonAction: () -> Void

    var body: some View {
        VStack(spacing: .DS.Padding.single) {
            Text(title)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(uiColor: .secondaryLabel))
            Text(description)
                .multilineTextAlignment(.center)
                .font(.footnote)
                .padding(.bottom, .DS.Padding.single)
                .foregroundColor(Color(uiColor: .tertiaryLabel))

            Button(action: buttonAction) {
                Text(buttonTitle)
                    .foregroundColor(Color(uiColor: Constants.retryTextColor))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(uiColor: Constants.retryBackgroundColor))
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    ContentLoadingErrorView(
        title: "Unable to load avatars",
        description: "There was an issue loading your avatars. Please try again in a few minutes.",
        buttonTitle: "Retry",
        buttonAction: {}
    )
}
