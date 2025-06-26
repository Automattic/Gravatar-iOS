import Analytics
import Gravatar
import SwiftUI

struct AvatarPickerView: View {
    let onLogout: () -> Void
    @StateObject var avatarPickerModel: AvatarPickerViewModel
    @State var forceRefreshHeader: Bool = false

    init(avatarPickerModel: AvatarPickerViewModel, onLogout: @escaping () -> Void) {
        self._avatarPickerModel = StateObject(wrappedValue: avatarPickerModel)
        self.onLogout = onLogout
    }

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
        }
        .ignoresSafeArea(.container, edges: .top)
    }

    func profileView(with profile: Profile) -> some View {
        Text(profile.displayName)
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
