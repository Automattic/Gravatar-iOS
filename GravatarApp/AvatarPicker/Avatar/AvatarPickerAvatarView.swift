import GravatarUI
import SwiftUI

struct AvatarPickerAvatarView: View {
    let avatar: AvatarImageModel
    let maxSize: CGFloat
    let minSize: CGFloat
    let shouldSelect: () -> Bool
    let avatarUploadErrorAction: (AvatarUploadErrorAction) -> Void
    let onActionSelected: (AvatarAction) -> Void
    let tapAction: (() -> Void)?

    @State private var uploadError: AvatarUploadErrorInfo?
    @State private var presentUploadErrorActions: Bool = false
    @State private var isTapped: Bool = false

    var body: some View {
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
        .frame(minWidth: minSize, maxWidth: maxSize, minHeight: minSize, maxHeight: maxSize)
        .background(Color(UIColor.secondarySystemBackground))
        .aspectRatio(1, contentMode: .fill)
        .shape(
            RoundedRectangle(cornerRadius: .avatarCornerRadius),
            borderColor: Color.clear,
            borderWidth: 0
        )
        .overlay {
            avatarOverlayView(for: avatar.state)
        }
        .transition(.opacity)
        .avatarUploadErrorDialog(isPresented: $presentUploadErrorActions, uploadError: $uploadError, action: { action in
            avatarUploadErrorAction(action)
        })
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(shouldSelect() ? .isSelected : [])
        .accessibilityLabel(Text(avatar.accessibilityLabel(altText: avatar.altText)))
        .scaleEffect(isTapped ? 0.95 : 1.0)
        .opacity(isTapped ? 0.8 : 1.0)
    }

    @ViewBuilder
    private func avatarOverlayView(for state: AvatarImageModel.State) -> some View {
        switch state {
        case .loading:
            loadingOverlayView()
        case .error(let supportsRetry, let errorMessage):
            errorOverlayView(supportsRetry: supportsRetry, errorMessage: errorMessage)
        case .loaded:
            loadedOverlayView(avatarSelected: shouldSelect())
        }
    }

    private func loadingOverlayView() -> some View {
        DimmingActivityIndicator()
            .cornerRadius(.avatarCornerRadius)
    }

    private func errorOverlayView(supportsRetry: Bool, errorMessage: String) -> some View {
        DimmingErrorButton {
            uploadError = AvatarUploadErrorInfo(avatarLocalID: avatar.id, supportsRetry: supportsRetry, errorMessage: errorMessage)
            presentUploadErrorActions = true
        }
        .cornerRadius(.avatarCornerRadius)
    }

    @ViewBuilder
    private func loadedOverlayView(avatarSelected: Bool) -> some View {
        if avatarSelected {
            selectedCheckmarkView()
        }
        AvatarActionsMenu(isAvatarSelected: avatarSelected) {
            isTapped = true
            withAnimation(.smooth) {
                isTapped = false
            }
            tapAction?()
        } label: {
            Color.clear
        } onActionSelected: { action in
            onActionSelected(action)
        }
    }

    private func selectedCheckmarkView() -> some View {
        ZStack(alignment: .bottomTrailing) {
            // We want an inner border, so we draw it in the overlay
            RoundedRectangle(cornerRadius: .avatarCornerRadius)
                .stroke(Color.primary, lineWidth: .selectedBorderWidth)
                .padding(1)
            CheckmarkCircleView()
                .padding(10)
                .transition(.scale)
        }
    }
}

extension CGFloat {
    fileprivate static let horizontalPadding: CGFloat = .DS.Padding.double
    fileprivate static let selectedBorderWidth: CGFloat = 3
    fileprivate static let avatarCornerRadius: CGFloat = 6
}

#Preview {
    let avatar = AvatarImageModel.preview_init()
    let avatarLoading = AvatarImageModel.preview_init(state: .loading)
    let avatarError = AvatarImageModel.preview_init(state: .error(
        supportsRetry: true,
        errorMessage: "Something went wrong. Retry?"
    ))
    let avatarErrorNoRetry = AvatarImageModel.preview_init(state: .error(
        supportsRetry: false,
        errorMessage: "Something terrible happened."
    ))
    AvatarPickerAvatarView(avatar: avatar, maxSize: 90, minSize: 80) {
        false
    } avatarUploadErrorAction: { _ in
    } onActionSelected: { _ in
    } tapAction: {}
    AvatarPickerAvatarView(avatar: avatar, maxSize: 90, minSize: 80) {
        true
    } avatarUploadErrorAction: { _ in
    } onActionSelected: { _ in
    } tapAction: {}
    AvatarPickerAvatarView(avatar: avatarLoading, maxSize: 90, minSize: 80) {
        true
    } avatarUploadErrorAction: { _ in
    } onActionSelected: { _ in
    } tapAction: {}
    AvatarPickerAvatarView(avatar: avatarError, maxSize: 90, minSize: 80) {
        true
    } avatarUploadErrorAction: { _ in
    } onActionSelected: { _ in
    } tapAction: {}
    AvatarPickerAvatarView(avatar: avatarErrorNoRetry, maxSize: 90, minSize: 80) {
        true
    } avatarUploadErrorAction: { _ in
    } onActionSelected: { _ in
    } tapAction: {}
}
