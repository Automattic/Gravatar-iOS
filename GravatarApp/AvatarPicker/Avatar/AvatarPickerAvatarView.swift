import GravatarUI
import SwiftUI

struct FailedUploadInfo {
    let avatarLocalID: String
    let supportsRetry: Bool
    let errorMessage: String
}

extension CGFloat {
    fileprivate static let horizontalPadding: CGFloat = .DS.Padding.double
    fileprivate static let selectedBorderWidth: CGFloat = 3
    fileprivate static let avatarCornerRadius: CGFloat = 6
}

struct AvatarPickerAvatarView: View {
    let avatar: AvatarImageModel
    let shouldSelect: () -> Bool
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
            .background(Color(UIColor.secondarySystemBackground))
            .aspectRatio(1, contentMode: .fill)
            .shape(
                RoundedRectangle(cornerRadius: .avatarCornerRadius),
                borderColor: Color.clear,
                borderWidth: 0
            )
            .overlay {
                switch avatar.state {
                case .loading:
                    DimmingActivityIndicator()
                        .cornerRadius(.avatarCornerRadius)
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
                    .cornerRadius(.avatarCornerRadius)
                case .loaded:
                    if shouldSelect() {
                        ZStack {
                            // We want an inner border, so we draw it in the overlay
                            RoundedRectangle(cornerRadius: .avatarCornerRadius)
                                .stroke(Color.primary, lineWidth: .selectedBorderWidth)
                                .padding(1)
                            CheckmarkCircleView()
                                .transition(.scale)
                        }
                    } else {
                        EmptyView()
                    }
                }
            }
            .transition(.opacity)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(shouldSelect() ? .isSelected : [])
        .accessibilityLabel(Text(avatar.accessibilityLabel(altText: avatar.altText)))
    }
}

#Preview {
    let avatar = AvatarImageModel.preview_init(
        id: "1",
        source: .remote(url: "https://gravatar.com/userimage/110207384/aa5f129a2ec75162cee9a1f0c472356a.jpeg?size=256")
    )
    AvatarPickerAvatarView(avatar: avatar) {
        false
    } onFailedUploadTapped: { _ in
    } onActionTap: { _ in
    }
}
