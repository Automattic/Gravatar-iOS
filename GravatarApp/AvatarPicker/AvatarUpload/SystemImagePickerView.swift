import ImagePlayground
import PhotosUI
import SwiftUI

enum ImagePickerSource: CaseIterable, Identifiable {
    case photoLibrary
    case camera
    case playground

    static var allCases: [ImagePickerSource] {
        var cases: [ImagePickerSource] = [.camera, .photoLibrary]
        if #available(iOS 18.2, *) {
            if EnvironmentValues().supportsImagePlayground {
                cases.append(.playground)
            }
        }
        return cases
    }

    var id: Int {
        self.hashValue
    }
}

struct ImagePicker<Label>: View where Label: View {
    let sourceType: ImagePickerSource

    @ViewBuilder var label: () -> Label

    let onImageSelected: (UIImage) -> Void

    @State private var imagePickerSelectedItem: ImagePickerItem?
    @State private var presentPicker: Bool = false

    var body: some View {
        Button {
            presentPicker = true
        } label: {
            label()
        }
        .modifier(ImagePlaygroundModifier(
            isPresented: Binding(
                get: { sourceType == .playground && presentPicker },
                set: { presentPicker = $0 }
            ),
            sourceImage: nil,
            onCompletion: { image in
                onImageEdited(image)
            }
        ))
        .sheet(
            isPresented: Binding(get: {
                sourceType != .playground && presentPicker
            }, set: { presentPicker = $0 }),
            content: {
                // This allows to present different kind of pickers for different sources.
                displayImagePicker(for: sourceType)
                    .sheet(item: $imagePickerSelectedItem, content: { item in
                        imageEditor(with: item)
                    })
            }
        )
    }

    func imageEditor(with item: ImagePickerItem) -> some View {
        ImageEditor(
            item: item,
            onEditComplete: { image in
                onImageEdited(image)
            },
            onCancel: {
                imagePickerSelectedItem = nil
            }
        )
    }

    private func onImageEdited(_ image: UIImage) {
        imagePickerSelectedItem = nil
        presentPicker = false
        onImageSelected(image)
    }

    @ViewBuilder
    private func displayImagePicker(for source: ImagePickerSource) -> some View {
        switch source {
        case .camera:
            ZStack {
                Color.black.ignoresSafeArea(edges: .all)
                CameraImagePicker { item in
                    pickerDidSelectImage(item)
                }
            }
        case .photoLibrary:
            PhotosImagePicker { item in
                pickerDidSelectImage(item)
            } onCancel: {
                presentPicker = false
            }.ignoresSafeArea()
        case .playground:
            EmptyView()
        }
    }

    private func pickerDidSelectImage(_ item: ImagePickerItem) {
//        UIApplication.shared.dismissKeyboard()
        imagePickerSelectedItem = item
    }
}

extension ImagePickerSource {
    var iconName: String {
        switch self {
        case .camera:
            "camera.fill"
        case .photoLibrary:
            "photo.on.rectangle.angled.fill"
        case .playground:
            "apple.image.playground.fill"
        }
    }

    var localizedTitle: String {
        switch self {
        case .photoLibrary:
            NSLocalizedString(
                "SystemImagePickerView.Source.PhotoLibrary.title",
                value: "Photos",
                comment: "An option in a menu that display the user's Photo Library and allow them to choose a photo from it"
            )
        case .camera:
            NSLocalizedString(
                "SystemImagePickerView.Source.Camera.title",
                value: "Camera",
                comment: "An option in a menu that will display the camera for taking a picture"
            )
        case .playground:
            NSLocalizedString(
                "SystemImagePickerView.Source.Playground.title",
                value: "AI",
                comment: "An option to show the image playground"
            )
        }
    }
}

struct ImagePickerItem: Identifiable, Sendable {
    let id: String
    let image: UIImage
}
