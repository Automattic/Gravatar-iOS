import Foundation
import SwiftUI

struct ImagePlaygroundModifier: ViewModifier {
    @Binding var isPresented: Bool
    @State private var playgroundSelectedItem: ImagePickerItem?

    let sourceImage: Image?
    let onCompletion: (UIImage) -> Void
    let onCancellation: (() -> Void)? = nil

    func body(content: Content) -> some View {
        content
            .imagePlaygroundSheetIfAvailable(
                isPresented: $isPresented,
                sourceImage: sourceImage,
                onCompletion: { url in
                    if let image = UIImage(contentsOfFile: url.relativePath) {
                        playgroundSelectedItem = ImagePickerItem(id: url.absoluteString, image: image)
                    }
                },
                onCancellation: onCancellation
            )
            .sheet(item: $playgroundSelectedItem, content: { item in
                imageEditor(with: item)
            })
    }

    private func imageEditor(with item: ImagePickerItem) -> some View {
        ImageEditor(
            item: item,
            onEditComplete: { image in
                playgroundSelectedItem = nil
                self.onCompletion(image)
            },
            onCancel: {
                playgroundSelectedItem = nil
            }
        )
    }
}
