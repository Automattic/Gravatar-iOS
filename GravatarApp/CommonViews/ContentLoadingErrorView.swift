import SwiftUI

struct ContentLoadingErrorView: View {
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
            }
            .buttonStyle(.actionButton(style: .primary))
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
