import Gravatar
import SwiftData
import SwiftUI

struct RootTabView: View {
    @StateObject private var avatarPickerViewModel: AvatarPickerViewModel
    @StateObject private var editProfileViewModel: EditProfileViewModel
    @StateObject private var shareViewModel: ShareViewModel
    @StateObject private var toastManager: ToastManager
    @StateObject private var modalManager = ModalPresentationManager()

    let session: UserSession

    let onLogout: () -> Void

    init(userSession: UserSession, context: ModelContext, onLogout: @escaping () -> Void) {
        self.session = userSession
        self.onLogout = onLogout

        let toastManager = ToastManager()
        _toastManager = StateObject(wrappedValue: toastManager)

        _avatarPickerViewModel = StateObject(wrappedValue: AvatarPickerViewModel(userSession: userSession, toastManager: toastManager))
        _editProfileViewModel = StateObject(wrappedValue: EditProfileViewModel(userSession: userSession, toastManager: toastManager))
        _shareViewModel = StateObject(wrappedValue: ShareViewModel(userSession: userSession))
    }

    var body: some View {
        TabView {
            Group {
                // MARK: - First tab

                GravatarTab(avatarPickerViewModel: avatarPickerViewModel, onLogout: onLogout)

                // MARK: - Second tab

                ProfileTab(editProfileViewModel: editProfileViewModel)

                // MARK: - Third tab

                ShareTab(viewModel: shareViewModel, avatarForceRefresh: $avatarPickerViewModel.forceRefreshAvatar)
            }
            // Needed to be added inside the TabView for the toast to follow the bottom safe area guide.
            .addToastContainer(manager: toastManager)
        }
        .environmentObject(session)
        .environmentObject(modalManager)
        .onAppear {
            Task {
                await avatarPickerViewModel.fetchAvatars()
            }
        }
        .modalPresentation(manager: modalManager)
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
            Label("Gravatar", image: .gravatarTab)
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
            Label(Localized.profileTabTitle, image: .profileTab)
        }
    }
}

struct ShareTab: View {
    @ObservedObject var viewModel: ShareViewModel
    @Binding var avatarForceRefresh: Bool

    var body: some View {
        NavigationStack {
            BackgroundColorView(color: .secondarySystemBackground) {
                ShareView(
                    viewModel: viewModel,
                    forceRefreshAvatar: $avatarForceRefresh
                )
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .tabItem {
            Label(Localized.shareTabTitle, image: .shareTab)
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

private enum Localized {
    static let profileTabTitle = NSLocalizedString(
        "Tabs.Profile.title",
        value: "Profile",
        comment: "Title for the profile tab"
    )

    static let shareTabTitle = NSLocalizedString(
        "Tabs.Share.title",
        value: "Share",
        comment: "Title for the share tab"
    )
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
