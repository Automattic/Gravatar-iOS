import SwiftUI

struct ImagePickerSectionView: View {
    let onImageSelected: (UIImage) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 0) {
                Text(Localized.sectionHeader)
                    .font(.headline)
                Text(Localized.sectionDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack {
                ForEach(ImagePickerSource.allCases, id: \.id) { source in
                    ImagePicker(sourceType: source) {
                        uploadAvatarButton(title: source.localizedTitle, systemImage: source.iconName)
                    } onImageSelected: { image in
                        onImageSelected(image)
                    }
                }
            }
        }
    }

    func uploadAvatarButton(title: String, systemImage: String) -> some View {
        Label {
            Text(title)
                .font(.subheadline)
        } icon: {
            Image(systemName: systemImage)
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
    static let sectionDescription = NSLocalizedString(
        "AvatarPicker.UploadSection.description",
        value: "It’s been 87 days since you updated your avatar.",
        comment: "Description for the section with the upload image buttons"
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
