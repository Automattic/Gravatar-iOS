import SwiftUI

struct RefreshControl: UIViewRepresentable {
    let animated: Bool
    let opacity: CGFloat

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let refresh = UIActivityIndicatorView(style: .large)
        if animated {
            refresh.startAnimating()
        } else {
            refresh.stopAnimating()
        }
        refresh.hidesWhenStopped = false
        refresh.alpha = opacity
        refresh.color = .systemBackground
        return refresh
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        if animated {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
        if opacity == 0 {
            UIView.animate(withDuration: 0.25, animations: {
                uiView.alpha = opacity
            })
        } else {
            uiView.alpha = opacity
        }
    }
}
