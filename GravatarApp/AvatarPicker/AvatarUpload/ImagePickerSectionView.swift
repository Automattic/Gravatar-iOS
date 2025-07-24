import SwiftUI

struct ImagePickerSectionView: View {
    let onImageSelected: (UIImage) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 0) {
                Text(Localized.sectionHeader)
                    .font(.headline)
                Text(Localized.sectionSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack {
                ForEach(ImagePickerSource.allCases, id: \.id) { source in
                    ImagePicker(sourceType: source) {
                        uploadAvatarButton(title: source.localizedTitle, icon: source.icon)
                    } onImageSelected: { image in
                        onImageSelected(image)
                    }
                }
            }
        }
    }

    func uploadAvatarButton(title: String, icon: ImagePickerSource.Icon) -> some View {
        Label {
            Text(title)
                .font(.subheadline)
        } icon: {
            Group {
                switch icon {
                case .system(let systemImage):
                    Image(systemName: systemImage)
                case .custom(let resource):
                    Image(resource)
                }
            }
            .font(.title)
        }
        .labelStyle(.vertical)
        .foregroundStyle(Color.DS.bluishColor)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color.DS.bluishColor.opacity(0.15))
        .cornerRadius(12)
    }
}

private enum Localized {
    static let sectionHeader = NSLocalizedString(
        "AvatarPicker.UploadSection.header",
        value: "Get a new look",
        comment: "Title for the section with the upload image buttons"
    )
    static let sectionSubtitle = NSLocalizedString(
        "AvatarPicker.UploadSection.subtitle",
        value: "Let your personality shine with a new avatar.",
        comment: "Subtitle for the section with the upload image buttons"
    )
}

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: LabelStyle.Configuration) -> some View {
        VStack(spacing: 8) {
            configuration.icon
            configuration.title
        }
    }
}

extension LabelStyle where Self == VerticalLabelStyle {
    @MainActor static var vertical: VerticalLabelStyle {
        VerticalLabelStyle()
    }
}

#Preview("Avatar Upload") {
    ImagePickerSectionView { _ in
    }
}
