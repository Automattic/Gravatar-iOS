import SwiftUI

struct AvatarActionsMenu<Label>: View where Label: View {
    let isAvatarSelected: Bool
    let label: () -> Label
    let onActionSelected: (AvatarAction) -> Void

    var body: some View {
        actionsMenu(isSelected: isAvatarSelected, label: label)
    }

    func actionsMenu(isSelected: Bool, label: () -> Label) -> some View {
        Menu {
            Section {
                if !isSelected {
                    button(for: .select)
                }
                button(for: .share)
                // TODO: We might use this soon, so keeping it commented for now
                /**
                 if #available(iOS 18.2, *) {
                     if EnvironmentValues().supportsImagePlayground {
                         button(for: .playground)
                     }
                 }
                  */
                button(for: .altText)
            }
            Section {
                button(for: .delete)
            }
        } label: {
            label()
        }
    }

    private func button(
        for action: AvatarAction,
        isSelected selected: Bool = false,
        systemImageWhenSelected systemImage: String = "checkmark"
    ) -> some View {
        Button(role: action.role) {
            onActionSelected(action)
        } label: {
            buttonLabel(forAction: action)
        }
    }

    private func buttonLabel(forAction action: AvatarAction, title: String? = nil, systemImage: String) -> SwiftUI.Label<Text, Image> {
        buttonLabel(forAction: action, title: title, image: Image(systemName: systemImage))
    }

    private func buttonLabel(forAction action: AvatarAction, title: String? = nil, image: Image? = nil) -> SwiftUI.Label<Text, Image> {
        SwiftUI.Label {
            Text(title ?? action.localizedTitle)
        } icon: {
            image ?? action.icon
        }
    }
}
