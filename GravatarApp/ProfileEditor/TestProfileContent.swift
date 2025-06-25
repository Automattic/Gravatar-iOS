import Analytics
import Gravatar
import SwiftUI

struct TestProfileContent: View {
    @State private var profile: Profile

    let onLogout: () -> Void

    init(profile: Profile, onLogout: @escaping () -> Void) {
        self._profile = State(initialValue: profile)
        self.onLogout = onLogout
    }

    var body: some View {
        VStack {
            profileView(with: profile)
            Button("Logout") {
                onLogout()
            }
            .padding(.bottom)

            // Add some content to make it scroll
            ForEach(1 ... 50, id: \.self) { i in
                Text("Item \(i)")
                    .font(.system(size: 16))
            }
        }
        .padding()
    }

    func profileView(with profile: Profile) -> some View {
        Text(profile.displayName)
    }
}
