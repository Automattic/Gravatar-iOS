import SwiftUI

extension CGFloat {
    static let maxAvatarWidth: CGFloat = 100
    fileprivate static let minAvatarWidth: CGFloat = 80
    fileprivate static let avatarSpacing: CGFloat = 2
}

struct AvatarGrid: View {
    @ObservedObject var grid: AvatarGridModel

    let onAvatarActionSelected: (AvatarImageModel, AvatarAction) -> Void
    let avatarUploadErrorAction: (AvatarUploadErrorAction) -> Void

    var body: some View {
        let columns: [GridItem] = [GridItem(
            .adaptive(
                minimum: .minAvatarWidth,
                maximum: .maxAvatarWidth
            ),
            spacing: .avatarSpacing
        )]

        LazyVGrid(columns: columns, spacing: .avatarSpacing) {
            ForEach(grid.avatars) { avatar in
                avatarView(for: avatar, maxSize: .maxAvatarWidth, minSize: .minAvatarWidth)
            }
        }
    }

    // MARK: - Views

    fileprivate func avatarView(for avatar: AvatarImageModel, maxSize: CGFloat, minSize: CGFloat) -> some View {
        AvatarPickerAvatarView(
            avatar: avatar,
            maxSize: maxSize,
            minSize: minSize,
            shouldSelect: {
                grid.selectedAvatar?.id == avatar.id
            },
            avatarUploadErrorAction: avatarUploadErrorAction,
            onActionSelected: { action in
                onAvatarActionSelected(avatar, action)
            }
        )
    }

    // MARK: - Helpers
}

#Preview {
    let newAvatarModel: @Sendable (UIImage?) -> AvatarImageModel = { image in
        AvatarImageModel.preview_init(id: UUID().uuidString, source: .local(image: image ?? UIImage()))
    }
    let selectedModel = newAvatarModel(nil)
    let grid = AvatarGridModel(
        avatars: [selectedModel, newAvatarModel(nil)]
    )
    grid.selectAvatar(selectedModel)

    return VStack {
        AvatarGrid(grid: grid) { avatar, _ in
            grid.selectAvatar(withID: avatar.id)
        } avatarUploadErrorAction: { _ in }
            .padding()
        Button("Add avatar cell") {
            grid.append(newAvatarModel(nil))
        }
    }
}
