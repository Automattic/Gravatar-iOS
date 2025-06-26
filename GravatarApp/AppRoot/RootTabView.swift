import Gravatar
import SwiftUI

struct RootTabView: View {
    @ObservedObject var avatarPickerModel: AvatarPickerViewModel

    let onLogout: () -> Void

    var body: some View {
        TabView {
            // MARK: - First tab

            GravatarTab(avatarPickerModel: avatarPickerModel, onLogout: onLogout)

            // MARK: - Second tab

            ProfileTab()

            // MARK: - Third tab

            ShareTab()
        }
        .onAppear {
            Task {
                await avatarPickerModel.fetchAvatars()
            }
        }
        .transition(.opacity)
    }
}

struct GravatarTab: View {
    @StateObject var avatarPickerModel: AvatarPickerViewModel

    let onLogout: () -> Void

    var body: some View {
        BackgroundColorView(color: .secondarySystemBackground) {
            AvatarPickerView(avatarPickerModel: avatarPickerModel, onLogout: onLogout)
        }
        .tabItem {
            Label("Gravatar", image: "gravatar-logo")
        }
    }
}

struct ProfileTab: View {
    var body: some View {
        BackgroundColorView(color: .secondarySystemBackground) {
            ProfileEditorView()
        }
        .tabItem {
            Label("Profile", systemImage: "brain.filled.head.profile")
        }
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
        avatarPickerModel: .preview_init(
            avatars: [
                .init(
                    id: "1",
                    source: .local(image: .init(systemName: "person")!),
                    state: .loaded,
                    isSelected: true,
                    altText: ""
                ),
            ]
        ),
        onLogout: {}
    )
}
#endif
