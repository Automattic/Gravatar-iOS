import Analytics
import Gravatar
import SwiftUI

struct AvatarPickerView: View {
    @ObservedObject var avatarPickerModel: AvatarPickerViewModel
    let onLogout: () -> Void

    @State private var forceRefreshHeader: Bool = false
    @State private var avatarToDelete: AvatarImageModel?
    @State private var altTextAvatarEdit: AvatarImageModel?

    @EnvironmentObject var overlayManaegr: OverlayManager

    var headerAvatarURL: URL? {
        AvatarURL(
            with: .hashID(avatarPickerModel.userSession.profile.hash),
            options: .init(preferredSize: .pixels(256))
        )?.url
    }

    var body: some View {
        VStack(spacing: 0) {
            AnimatedHeaderScrollView(animationBehavior: .automatic) { topSafeArea in
                AvatarPickerScrollableHeaderView(
                    topSafeArea: topSafeArea,
                    imageURL: headerAvatarURL,
                    forceRefresh: $forceRefreshHeader
                )
            } stickyHeader: { opacity, safeAreaInsets in
                AvatarPickerStickyHeaderView(
                    opacity: opacity,
                    safeAreaInsets: safeAreaInsets,
                    imageURL: headerAvatarURL,
                    forceRefresh: $forceRefreshHeader
                )
            } content: {
                Group {
                    if let error = avatarPickerModel.gridResponseStatus?.error() {
                        // TODO: Temporally render error message for development puposes.
                        Text(String(describing: error))
                    }
                    if avatarPickerModel.isAvatarsLoading {
                        ProgressView()
                            .padding()
                        Spacer()
                    } else {
                        ImagePickerSectionView(onImageSelected: { selectedImage in
                            Task {
                                await avatarPickerModel.upload(selectedImage)
                            }
                        })
                        .appPadding()
                        gridView()
                            .transition(.opacity)
                    }
                }
            } buttonMenuItems: {
                Button(
                    "Logout",
                    systemImage: "iphone.and.arrow.forward.outward",
                    role: .destructive
                ) {
                    onLogout()
                }
            }
        }
        .avatarDeletionDialog(avatar: $avatarToDelete, deleteAction: { avatar in
            Task {
                await avatarPickerModel.delete(avatar)
            }
        })
        .altTextEditor(avatarModel: $altTextAvatarEdit) { _ in
            altTextAvatarEdit = nil
        }
    }

    func gridView() -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Previous avatars")
                    .font(.headline)
                Text("Tap for options")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            AvatarGrid(
                grid: avatarPickerModel.grid,
                onAvatarActionSelected: avatarAction,
                avatarUploadErrorAction: avatarUploadErrorAction
            )
        }
        .appPadding()
    }

    // MARK: - Actions

    private func avatarAction(avatar: AvatarImageModel, action: AvatarAction) {
        switch action {
        case .select:
            Task {
                _ = await avatarPickerModel.selectAvatar(with: avatar.id)
                forceRefreshHeader = true
            }
        case .delete:
            avatarToDelete = avatar
        case .altText:
            overlayManaegr.present {
                AltTextEditorView(avatar: avatar) { _ in
                    overlayManaegr.dismiss()
                } onCancel: {
                        overlayManaegr.dismiss()
                }
            }
        default:
            print("Action not implemented")
        }
    }

    private func avatarUploadErrorAction(action: AvatarUploadErrorAction) {
        switch action {
        case .delete(let avatarID):
            avatarPickerModel.deleteFailed(avatarID)
        case .retry(let avatarID):
            Task {
                await avatarPickerModel.retryUpload(of: avatarID)
            }
        }
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
        .init(id: "3", source: .remote(url: ""), state: .loading, isSelected: false, altText: ""),
    ]), onLogout: {})
}
#endif
