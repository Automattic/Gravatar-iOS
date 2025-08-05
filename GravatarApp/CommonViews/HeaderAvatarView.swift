import GravatarUI
import SwiftUI

struct HeaderAvatarView: View {
    let imageURL: URL?
    let showLoading: Bool
    @Binding var forceRefresh: Bool

    let placeholderColor: Color
    let transaction: Transaction
    let urlSession: URLSession

    init(
        imageURL: URL?,
        showLoading: Bool = false,
        forceRefresh: Binding<Bool>,
        placeholderColor: Color = .secondary,
        animation: Animation? = nil,
        urlSession: URLSession = GravatarURLSession.shared.urlSession
    ) {
        self.imageURL = imageURL
        self.showLoading = showLoading
        self._forceRefresh = forceRefresh
        self.placeholderColor = placeholderColor
        self.transaction = Transaction(animation: animation)
        self.urlSession = urlSession
    }

    var body: some View {
        AvatarView(
            url: imageURL,
            placeholderView: {
                placeholderColor
            },
            urlSession: urlSession,
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
