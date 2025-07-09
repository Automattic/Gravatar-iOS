import GravatarUI
import SwiftUI

struct HeaderAvatarView<Placeholder>: View where Placeholder: View {
    let imageURL: URL?
    let showLoading: Bool
    @Binding var forceRefresh: Bool

    let placeholderView: () -> Placeholder

    var body: some View {
        AvatarView(
            url: imageURL,
            placeholderView: {
                placeholderView()
            },
            oneTimeForceRefresh: $forceRefresh,
            loadingView: {
                showLoading ?
                    AnyView(ProgressView().progressViewStyle(.circular))
                    :
                    AnyView(EmptyView())
            }
        )
    }
}
