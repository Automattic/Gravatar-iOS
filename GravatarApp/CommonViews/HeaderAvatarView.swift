import GravatarUI
import SwiftUI

struct HeaderAvatarView: View {
    let imageURL: URL?
    let showLoading: Bool
    @Binding var forceRefresh: Bool

    let placeholderColor: Color
    let transaction: Transaction

    init(
        imageURL: URL?,
        showLoading: Bool = false,
        forceRefresh: Binding<Bool>,
        placeholderColor: Color = .secondary,
        animation: Animation? = nil
    ) {
        self.imageURL = imageURL
        self.showLoading = showLoading
        self._forceRefresh = forceRefresh
        self.placeholderColor = placeholderColor
        self.transaction = Transaction(animation: animation)
    }

    var body: some View {
        AvatarView(
            url: imageURL,
            placeholderView: {
                placeholderColor
            },
            oneTimeForceRefresh: $forceRefresh,
            loadingView: {
                showLoading ?
                    AnyView(ProgressView().progressViewStyle(.circular))
                    :
                    AnyView(EmptyView())
            },
            transaction: transaction
        )
        .allowsHitTesting(false)
    }
}
