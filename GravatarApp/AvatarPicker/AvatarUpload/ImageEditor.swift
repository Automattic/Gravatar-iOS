import SwiftUI

/// View with the full image edition experience.
struct ImageEditor: View {
    let item: ImagePickerItem
    let onEditComplete: (UIImage) -> Void
    let onCancel: (() -> Void)?

    var body: some View {
        ImageCropper(inputImage: item.image) { croppedImage in
            Task { @MainActor in
                onEditComplete(croppedImage)
            }
        } onCancel: {
            onCancel?()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    if let image = UIImage(systemName: "person") {
        ImageEditor(
            item: .init(id: "", image: image)
        ) { _ in
        }
        onCancel: {}
    }
}
