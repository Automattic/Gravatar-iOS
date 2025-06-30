import Analytics
import Gravatar
import SwiftUI

struct ProfileEditContentView: View {
    private enum Constants {
        static let primaryFont: Font = .subheadline
        static let sectionHeaderFont: Font = .subheadline.weight(.semibold)
        static let footerFont: Font = .footnote
        static let horizontalPadding: CGFloat = .DS.Padding.double
        static let vStackVerticalSpacing: CGFloat = .DS.Padding.medium
    }

    @ObservedObject var viewModel: EditProfileViewModel

    var body: some View {
        VStack {
            Text("Profile Editor!")

            // Add some content to make it scroll
            ForEach(1 ... 50, id: \.self) { i in
                Text("Item \(i)")
                    .font(.system(size: 16))
            }
        }
        .padding()
    }
}
