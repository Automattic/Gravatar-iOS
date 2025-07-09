import Gravatar
import SwiftData
import SwiftUI

struct RootTabView: View {
    @StateObject private var avatarPickerViewModel: AvatarPickerViewModel
    @StateObject private var editProfileViewModel: EditProfileViewModel

    let session: UserSession

    let onLogout: () -> Void

    init(userSession: UserSession, context: ModelContext, onLogout: @escaping () -> Void) {
        self.session = userSession
        self.onLogout = onLogout

        _avatarPickerViewModel = StateObject(wrappedValue: AvatarPickerViewModel(userSession: userSession))
        _editProfileViewModel = StateObject(wrappedValue: EditProfileViewModel(userSession: userSession))
    }

    var body: some View {
        TabView {
            // MARK: - First tab

            GravatarTab(avatarPickerViewModel: avatarPickerViewModel, onLogout: onLogout)

            // MARK: - Second tab

            ProfileTab(editProfileViewModel: editProfileViewModel)

            // MARK: - Third tab

            ShareTab()
        }
        .environmentObject(session)
        .onAppear {
            Task {
                await avatarPickerViewModel.fetchAvatars()
            }
        }
        .transition(.opacity)
    }
}

struct GravatarTab: View {
    @ObservedObject var avatarPickerViewModel: AvatarPickerViewModel
    let onLogout: () -> Void

    var body: some View {
        BackgroundColorView(color: .secondarySystemBackground) {
            AvatarPickerView(avatarPickerModel: avatarPickerViewModel, onLogout: onLogout)
        }
        .tabItem {
            Label("Gravatar", image: "gravatar-logo")
        }
    }
}

struct ProfileTab: View {
    @ObservedObject var editProfileViewModel: EditProfileViewModel

    @EnvironmentObject var session: UserSession

    var body: some View {
        BackgroundColorView(color: .secondarySystemBackground) {
            content(editProfileViewModel: editProfileViewModel, userSession: session)
        }
        .ignoresSafeArea()
        .tabItem {
            Label("Profile", systemImage: "brain.filled.head.profile")
        }
    }

    func content(editProfileViewModel: EditProfileViewModel, userSession: UserSession) -> some View {
        let profileView = ProfileEditContentView(viewModel: editProfileViewModel)

        return CollapsableHeaderScrollView<ProfileEditContentView>(
            headerContentView: ProfileHeaderContentView(userSession: userSession),
            scrollableContent: .swiftUI(profileView)
        )
    }
}

struct ShareTab: View {
    var body: some View {
        NavigationStack {
            BackgroundColorView(color: .secondarySystemBackground) {
                Text("Share!")
            }
            .navigationTitle("Share")
            .navigationBarItems(
                trailing: Button("Share", systemImage: "square.and.arrow.up", action: {})
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .tabItem {
            Label("Share", systemImage: "qrcode")
        }
    }
}

struct BackgroundColorView<Content>: View where Content: View {
    let color: UIColor
    let content: () -> Content

    var body: some View {
        ZStack {
            Color(uiColor: color)
                .ignoresSafeArea()
            content()
        }
    }
}

#if DEBUG // Needed when we use `Profile.testProfile on Previews`
#Preview {
    RootTabView(
        userSession: UserSession(profile: .testProfile, accessToken: "", context: .testContext),
        context: .testContext,
        onLogout: {}
    )
}
#endif
