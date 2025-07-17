import SwiftUI

final class ModalPresentationManager: ObservableObject {
    @Published var content: (() -> AnyView)? = nil
    @Published var isShowingContent: Bool = false

    func present(@ViewBuilder content: @escaping () -> some View) {
        self.content = { AnyView(content()) }
        isShowingContent = true
    }

    func dismiss() {
        content = nil
        isShowingContent = false
    }
}
