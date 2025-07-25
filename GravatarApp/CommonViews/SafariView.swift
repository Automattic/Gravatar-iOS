import SafariServices
import SwiftUI

private struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        // No updates needed for SafariViewController
    }
}

extension View {
    func presentSafariView(url: Binding<URL?>) -> some View {
        self.sheet(item: url) { url in
            SafariView(url: url)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
