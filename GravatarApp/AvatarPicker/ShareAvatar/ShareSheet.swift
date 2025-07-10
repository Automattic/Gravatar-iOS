import SwiftUI

/// Use `ShareLink` after iOS 16+.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let activities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: activities)
        controller.excludedActivityTypes = [
            .print,
            .postToWeibo,
            .postToTencentWeibo,
            .addToReadingList,
            .postToVimeo,
            .openInIBooks,
        ]

        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No need to update dynamically
    }
}
