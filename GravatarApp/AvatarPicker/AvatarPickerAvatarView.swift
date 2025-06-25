import SwiftUI
import GravatarUI

struct FailedUploadInfo {
    let avatarLocalID: String
    let supportsRetry: Bool
    let errorMessage: String
}

struct AvatarPickerAvatarView: View {
    let avatar: AvatarImageModel
    let maxLength: CGFloat
    let minLength: CGFloat
    let shouldSelect: () -> Bool
    let onAvatarTap: (AvatarImageModel) -> Void
    let onFailedUploadTapped: (FailedUploadInfo) -> Void
    let onActionTap: (AvatarAction) -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AvatarView(
                url: avatar.url,
                placeholderView: {
                    avatar.localImage?.resizable()
                },
                loadingView: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                },
                transaction: .init(animation: .smooth)
            )
            .scaledToFill()
            .frame(
                minWidth: minLength,
                maxWidth: maxLength,
                minHeight: minLength,
                maxHeight: maxLength
            )
            .background(Color(UIColor.secondarySystemBackground))
            .aspectRatio(1, contentMode: .fill)
            .shape(
                RoundedRectangle(cornerRadius: AvatarGridConstants.avatarCornerRadius),
                borderColor: Color(uiColor: .systemBlue),
                borderWidth: shouldSelect() ? AvatarGridConstants.selectedBorderWidth : 0
            )
            .overlay {
                switch avatar.state {
                case .loading:
                    DimmingActivityIndicator()
                        .cornerRadius(AvatarGridConstants.avatarCornerRadius)
                case .error(let supportsRetry, let errorMessage):
                    DimmingErrorButton {
                        onFailedUploadTapped(
                            .init(
                                avatarLocalID: avatar.id,
                                supportsRetry: supportsRetry,
                                errorMessage: errorMessage
                            )
                        )
                    }
                    .cornerRadius(AvatarGridConstants.avatarCornerRadius)
                case .loaded:
                    EmptyView()
                }
            }
            .transaction({ transaction in
                transaction.animation = .smooth
            })
            .onTapGesture {
                onAvatarTap(avatar)
            }
            switch avatar.state {
            case .loaded:
                actionsMenu()
            default:
                EmptyView()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(shouldSelect() ? .isSelected : [])
        .accessibilityLabel(Text(avatar.accessibilityLabel(altText: avatar.altText)))
        .accessibilityAction(named: shouldSelect() ? "" : .accessibilityAvatarHint) {
            if !shouldSelect() {
                onAvatarTap(avatar)
            }
        }
    }

    func ellipsisView() -> some View {
        Image("more-horizontal").renderingMode(.template)
            .tint(.white)
            .background(Color(uiColor: UIColor.black.withAlphaComponent(0.4)))
            .cornerRadius(2)
            .padding(CGFloat.DS.Padding.half)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(String.accessibilityAvatarOptionsLabel))
    }

    func actionsMenu() -> some View {
        Menu {
            Section {
                button(for: .share)
                if #available(iOS 18.2, *) {
                    if EnvironmentValues().supportsImagePlayground {
                        button(for: .playground)
                    }
                }
            }
            Section {
                button(for: .altText)
            }
            Section {
                button(for: .delete)
            }
        } label: {
            ellipsisView()
        }
    }

    private func button(
        for action: AvatarAction,
        isSelected selected: Bool = false,
        systemImageWhenSelected systemImage: String = "checkmark"
    ) -> some View {
        Button(role: action.role) {
            onActionTap(action)
        } label: {
            label(forAction: action)
        }
    }

    private func label(forAction action: AvatarAction, title: String? = nil, systemImage: String) -> Label<Text, Image> {
        label(forAction: action, title: title, image: Image(systemName: systemImage))
    }

    private func label(forAction action: AvatarAction, title: String? = nil, image: Image? = nil) -> Label<Text, Image> {
        Label {
            Text(title ?? action.localizedTitle)
        } icon: {
            image ?? action.icon
        }
    }
}

extension String {
    fileprivate static let accessibilityAvatarHint = NSLocalizedString(
        "Avatar.Accessibility.AvatarButton.Hint",
        value: "Select this avatar",
        comment: "Hint spoken outloud by VoiceOver when an avatar is selected"
    )
    fileprivate static let accessibilityAvatarOptionsLabel = NSLocalizedString(
        "Avatar.Accessibility.AvatarButton.OptionsLabel",
        value: "Avatar options",
        comment: "Accessibility label spoken outloud by VoiceOver when the avatar options button is selected"
    )
}

#Preview {
    let avatar = AvatarImageModel.preview_init(
        id: "1",
        source: .remote(url: "https://gravatar.com/userimage/110207384/aa5f129a2ec75162cee9a1f0c472356a.jpeg?size=256")
    )
    AvatarPickerAvatarView(avatar: avatar, maxLength: AvatarGridConstants.maxAvatarWidth, minLength: AvatarGridConstants.minAvatarWidth) {
        false
    } onAvatarTap: { _ in
    } onFailedUploadTapped: { _ in
    } onActionTap: { _ in
    }
}
