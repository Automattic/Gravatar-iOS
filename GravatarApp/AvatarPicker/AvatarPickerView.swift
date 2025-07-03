import Analytics
import Gravatar
import SwiftUI

struct AvatarPickerView: View {
    @ObservedObject var avatarPickerModel: AvatarPickerViewModel
    let onLogout: () -> Void

    @State private var forceRefreshHeader: Bool = false
    @State private var avatarToDelete: AvatarImageModel?

    var body: some View {
        VStack(spacing: 0) {
            AvatarPickerHeaderView(
                profile: $avatarPickerModel.profile,
                forceRefresh: $forceRefreshHeader,
                onActionPressed: { onLogout() }
            )
            if let error = avatarPickerModel.gridResponseStatus?.error() {
                // TODO: Temporally render error message for development puposes.
                Text(String(describing: error))
            }
            if avatarPickerModel.isAvatarsLoading {
                ProgressView()
                    .padding()
                Spacer()
            } else {
                gridView()
                    .transition(.opacity)
            }
        }
        .avatarDeletionDialog(avatar: $avatarToDelete, deleteAction: { avatar in
            Task {
                await avatarPickerModel.delete(avatar)
            }
        })
        .ignoresSafeArea(.container, edges: .top)
    }

    func gridView() -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Previous avatars")
                        .font(.headline)
                    Text("Tap for options")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                AvatarGrid(grid: avatarPickerModel.grid) { avatar, _ in
                    Task {
                        _ = await avatarPickerModel.selectAvatar(with: avatar.id)
                        forceRefreshHeader = true
                    }
                } onFailedUploadTapped: { _ in
                }
            }
            .padding()
        }
        .appPadding()
    }
}

extension View {
    func appPadding() -> some View {
        self.padding(16)
    }
}

#if DEBUG
#Preview {
    AvatarPickerView(avatarPickerModel: .preview_init(avatars: [
        .init(id: "1", source: .remote(url: ""), state: .loaded, isSelected: false, altText: ""),
        .init(id: "2", source: .remote(url: ""), state: .loaded, isSelected: true, altText: ""),
    ]), onLogout: {})
}
#endif
