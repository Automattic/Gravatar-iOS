import Gravatar
import SwiftData
import SwiftUI

struct RootTabView: View {
    @StateObject private var avatarPickerViewModel: AvatarPickerViewModel
    @StateObject private var editProfileViewModel: EditProfileViewModel
    @StateObject private var toastManager: ToastManager

    let session: UserSession

    let onLogout: () -> Void

    init(userSession: UserSession, context: ModelContext, onLogout: @escaping () -> Void) {
        self.session = userSession
        self.onLogout = onLogout

        let toastManager = ToastManager()
        _toastManager = StateObject(wrappedValue: toastManager)

        _avatarPickerViewModel = StateObject(wrappedValue: AvatarPickerViewModel(userSession: userSession, toastManager: toastManager))
        _editProfileViewModel = StateObject(wrappedValue: EditProfileViewModel(userSession: userSession, toastManager: toastManager))
    }

    var body: some View {
        TabView {
            Group {
                // MARK: - First tab

                GravatarTab(avatarPickerViewModel: avatarPickerViewModel, onLogout: onLogout)

                // MARK: - Second tab

                ProfileTab(editProfileViewModel: editProfileViewModel)

                // MARK: - Third tab

                ShareTab()
            }
            // Needed to be added inside the TabView for the toast to follow the bottom safe area guide.
            .addToastContainer(manager: toastManager)
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

    var body: some View {
        BackgroundColorView(color: .secondarySystemBackground) {
            ProfileEditorView(viewModel: editProfileViewModel)
        }
        .tabItem {
            Label("Profile", systemImage: "brain.filled.head.profile")
        }
    }
}

struct ShareTab: View {
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        NavigationStack {
            BackgroundColorView(color: .secondarySystemBackground) {
                ShareContentView(viewModel: ShareViewModel(userSession: userSession))
            }
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
