import SwiftUI

struct AvatarActionsMenu<Label>: View where Label: View {
    let isAvatarSelected: Bool
    let labelTapAction: (() -> Void)?
    let label: () -> Label
    let onActionSelected: (AvatarAction) -> Void

    @State var menuID: UUID = .init()

    var body: some View {
        actionsMenu(isSelected: isAvatarSelected, label: label)
    }

    func actionsMenu(isSelected: Bool, label: @escaping () -> Label) -> some View {
        MenuButton(label: label) {
            MenuSection {
                if !isSelected {
                    button(for: .select)
                }
                button(for: .share)

                // TODO: We might use this soon, so keeping it commented for now
//                 if #available(iOS 18.2, *) {
//                     if EnvironmentValues().supportsImagePlayground {
//                         button(for: .playground)
//                     }
//                 }
//                 button(for: .altText)
            }
            MenuSection {
                button(for: .delete)
            }
        }
        onMenuAppear: {
            labelTapAction?()
        }
    }

    private func button(for action: AvatarAction) -> MenuItem {
        MenuItem(
            action.localizedTitle,
            systemImage: action.icon,
            attributes: action.attribures,
            action: { onActionSelected(action) }
        )
    }
}
