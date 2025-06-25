import Analytics
import Gravatar
import SwiftUI

struct ContentView: View {
    @State private var profile: Profile

    let onLogout: () -> Void

    init(profile: Profile, onLogout: @escaping () -> Void) {
        self._profile = State(initialValue: profile)
        self.onLogout = onLogout
    }

    var body: some View {
        AvatarPickerHeaderView(profile: $profile)
        VStack(alignment: .center) {
            Spacer()
            Text("Profile View")
            Button("Logout") {
                onLogout()
            }
            Spacer()
        }
        .padding()
    }
}

#if DEBUG
#Preview {
    ContentView(profile: .testProfile, onLogout: {})
}
#endif
