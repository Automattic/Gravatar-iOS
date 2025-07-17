import Analytics
import Gravatar
import SwiftUI

struct AvatarPickerView: View {
    @ObservedObject var avatarPickerModel: AvatarPickerViewModel
    let onLogout: () -> Void

    @State private var avatarToDelete: AvatarImageModel?
    @State private var shareSheetItem: AvatarShareItem?

    var headerAvatarURL: URL? {
        AvatarURL(
            with: .hashID(avatarPickerModel.userSession.profile.hash),
            options: .init(preferredSize: .pixels(256))
        )?.url
    }

    var body: some View {
        VStack(spacing: 0) {
            AnimatedHeaderScrollView(animationBehavior: .automatic) { topPadding in
                AvatarPickerScrollableHeaderView(
                    topPadding: topPadding,
                    imageURL: headerAvatarURL,
                    forceRefresh: $avatarPickerModel.forceRefreshAvatar
                )
            } stickyHeader: { opacity, safeAreaInsets in
                AvatarPickerStickyHeaderView(
                    opacity: opacity,
                    safeAreaInsets: safeAreaInsets,
                    imageURL: headerAvatarURL,
                    forceRefresh: $avatarPickerModel.forceRefreshAvatar
                )
            } content: {
                Group {
                    ImagePickerSectionView(onImageSelected: { selectedImage in
                        Task {
                            await avatarPickerModel.upload(selectedImage)
                        }
                    })
                    .appPadding()
                    if let gridResponseStatus = avatarPickerModel.gridResponseStatus {
                        // Grid response has failed AND the grid is empty
                        if gridResponseStatus.error() != nil && avatarPickerModel.grid.isEmpty {
                            ContentLoadingErrorView.avatars {
                                Task {
                                    await avatarPickerModel.refresh()
                                }
                            }
                            .padding(.top, .DS.Padding.medium)
                            .padding(.horizontal, .DS.Padding.large)
                        } else {
                            gridView()
                                .transition(.opacity)
                        }
                    }
                    if avatarPickerModel.grid.isEmpty && avatarPickerModel.isAvatarsLoading {
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                }
                .readableContentWidth()
            } buttonMenuItems: {
                MainMenuOptions(profile: avatarPickerModel.userSession.profile)
            } onRefresh: {
                await avatarPickerModel.refresh()
            }
        }
        .avatarDeletionDialog(avatar: $avatarToDelete, deleteAction: { avatar in
            Task {
                await avatarPickerModel.delete(avatar)
            }
        })
        .avatarShareSheet(item: $shareSheetItem)
    }

    func gridView() -> some View {
        VStack(alignment: .leading, spacing: .DS.Padding.split) {
            VStack(alignment: .leading, spacing: 0) {
                Text(Localized.avatarGridTitle)
                    .font(.headline)
                Text(avatarPickerModel.grid.isEmpty ? Localized.avatarGridEmptySubtext : Localized.avatarGridSubtext)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if avatarPickerModel.shouldDisplayNoSelectedAvatarWarning {
                SimpleMessageView(message: Localized.noSelectedAvatar)
                    .frame(idealWidth: .infinity)
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
            }
        case .delete:
            avatarToDelete = avatar
        case .share:
            Task {
                if let fileURL = await avatarPickerModel.fetchAndSaveToFile(avatar: avatar) {
                    shareSheetItem = AvatarShareItem(id: avatar.id, fileURL: fileURL)
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

    enum Localized {
        static let avatarGridTitle = NSLocalizedString(
            "AvatarPicker.Grid.title",
            value: "Previous avatars",
            comment: "Title of the avatars grid"
        )
        static let avatarGridSubtext = NSLocalizedString(
            "AvatarPicker.Grid.subtext",
            value: "Tap for options.",
            comment: "A subtext that appears below the avatars grid title"
        )
        static let avatarGridEmptySubtext = NSLocalizedString(
            "AvatarPicker.Grid.Empty.label",
            value: "Your avatars will show up here.",
            comment: "A label displayed above an empty avatars grid."
        )
        static let noSelectedAvatar = NSLocalizedString(
            "AvatarPicker.Grid.NoSelectedAvatar",
            value: "No avatar selected. Showing the default avatar.",
            comment: "A warning message that appears above the avatars grid when there's no selected avatar."
        )
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
