import SwiftUI

extension CGFloat {
    static let maxAvatarWidth: CGFloat = 90
    fileprivate static let avatarSpacing: CGFloat = 2
}

struct AvatarGrid: View {
    @ObservedObject var grid: AvatarGridModel

    let onAvatarActionTap: (AvatarImageModel, AvatarAction) -> Void
    let onFailedUploadTapped: (FailedUploadInfo) -> Void

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let columnsCount = columsCount(for: totalWidth)
            let itemSize = itemSize(for: totalWidth, columnsCount: columnsCount)

            let columns = Array(
                repeating: GridItem(.fixed(itemSize), spacing: .avatarSpacing),
                count: columnsCount
            )

            LazyVGrid(columns: columns, spacing: .avatarSpacing) {
                ForEach(grid.avatars) { avatar in
                    Menu {
                        menuItems(for: avatar)
                    } label: {
                        avatarView(for: avatar, size: itemSize)
                    }
                }
            }
        }
    }

    // MARK: - Views

    fileprivate func avatarView(for avatar: AvatarImageModel, size: CGFloat) -> AvatarPickerAvatarView {
        AvatarPickerAvatarView(
            avatar: avatar,
            shouldSelect: {
                grid.selectedAvatar?.id == avatar.id
            },
            onFailedUploadTapped: onFailedUploadTapped,
            onActionTap: { action in
                onAvatarActionTap(avatar, action)
            }
        )
    }

    @ViewBuilder
    func menuItems(for avatar: AvatarImageModel) -> some View {
        Button(role: .none) {
            onAvatarActionTap(avatar, .delete)
        } label: {
            Label(
                title: { Text(AvatarAction.select.localizedTitle) },
                icon: { AvatarAction.select.icon }
            )
        }
    }

    // MARK: - Helpers

    func columsCount(for width: CGFloat) -> Int {
        max(
            Int((width + .avatarSpacing) / (.maxAvatarWidth + .avatarSpacing)),
            1
        )
    }

    func itemSize(for width: CGFloat, columnsCount: Int) -> CGFloat {
        (width - (CGFloat(columnsCount - 1) * .avatarSpacing)) / CGFloat(columnsCount)
    }
}

#Preview {
    let newAvatarModel: @Sendable (UIImage?) -> AvatarImageModel = { image in
        AvatarImageModel.preview_init(id: UUID().uuidString, source: .local(image: image ?? UIImage()))
    }
    let initialAvatarCell = newAvatarModel(nil)
    let grid = AvatarGridModel(
        avatars: [initialAvatarCell]
    )
    grid.selectAvatar(initialAvatarCell)

    return VStack {
        AvatarGrid(grid: grid) { avatar, _ in
            grid.selectAvatar(withID: avatar.id)
        } onFailedUploadTapped: { _ in
        }
        .padding()
        Button("Add avatar cell") {
            grid.append(newAvatarModel(nil))
        }
    }
}
