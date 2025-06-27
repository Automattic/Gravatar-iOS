import Analytics
import Gravatar
import SwiftUI

struct TestProfileContent: View {
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
