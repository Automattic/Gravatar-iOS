import SwiftUI

struct ImagePickerSectionView: View {
    let onImageSelected: (UIImage) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Get a new look")
                    .font(.headline)
                Text("It’s been 87 days since you updated your avatar.")
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
