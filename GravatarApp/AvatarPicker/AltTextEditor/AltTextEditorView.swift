import SwiftUI
import GravatarUI

struct AltTextEditorView: View {
    let avatar: AvatarImageModel?

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @State var altText: String = ""
    @State var charCount: Int = 0
    @State var isLoading: Bool = false
    @State var contentHeight: CGFloat = 0

    @FocusState var focused: Bool

    let onSave: (AvatarImageModel) async -> Void
    let onCancel: () -> Void

    var counterPadding: CGFloat {
        switch dynamicTypeSize {
        case let size where size <= .large: 10
        case let size where size < .xxxLarge: -10
        case let size where size >= .xxxLarge: -18
        default: 0
        }
    }

    var normalSizeTextEditorLayout: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack() {
                altTextField
            }
            characterCountText
                .padding(.bottom, counterPadding)
                .padding(.trailing, 10)
        }.padding(.bottom, 12)
    }

    var accessibilitySizeTextEditorLayout: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .top) {
                altTextField
            }
            characterCountText.padding(.top, -6).padding(.bottom, -4)
        }
    }

    var body: some View {
        // Scroll view helps detaching the height of the child view from the height of the parent view.
        // This avoids a UI problem while scrolling down the sheet with the keyboard being present.
        // GeometryReader also has the same effect. For now we want the content to scroll when the content grows.
        ScrollView {
            ZStack {
                VStack {
                    VStack(alignment: .center, spacing: 16) {
                        imageView
                        VStack(alignment: .leading) {
                            titleText
                            if dynamicTypeSize >= .accessibility1 {
                                accessibilitySizeTextEditorLayout
                            } else {
                                normalSizeTextEditorLayout
                            }
                            Text("This optional text can help describe and provide context to visually impaired people.")
                                .font(.footnote).foregroundStyle(.secondary)
                        }

                        actionButtons
//                            .disabled(isLoading)
                    }
                    .padding()
                }
                .padding(.bottom)
                .padding(.horizontal)
//                errorToast
            }
            .contentHeightReader($contentHeight)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(.regularMaterial)
        .onAppear {
            altText = avatar?.altText ?? ""
        }
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(radius: 12, x: 0, y: 8)
        .transition(.scale.combined(with: .opacity))
        .frame(maxWidth: 500, maxHeight: contentHeight)
    }

    var altTextField: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: Binding(
                get: { altText.normalizedAltText },
                set: { newAltText in
                    if newAltText.contains("\n") {
                        focused = false
                    }
                    altText = newAltText.normalizedAltText
                }
            ))
            .multilineTextAlignment(.leading)
            .contentMargins(.horizontal, 12)
            .contentMargins(.vertical, 8)
//            .frame(height: dynamicTypeSize >= .accessibility1 ? Constants.minAccessibilityLength : Constants.minLength)
            .frame(height: 120)
            .scrollContentBackground(.hidden)
            .background(focused ? Color.clear : Color.secondary.opacity(0.2))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.DS.bluishColor, lineWidth: focused ? 2 : 0)
            )
            .font(.body)
            .focused($focused)
            .submitLabel(.done)
            .transition(.opacity)
            .animation(.snappy, value: focused)

            if altText.count == 0 {
                Text(Localized.altTextPlaceholder)
                    // Exactly possitions placeholder over TextEditor text.
                    .padding(.leading, 16)
                    .padding(.top, 16)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }

    var titleText: some View {
        Text(Localized.pageTitle)
            .font(.subheadline)
            .fontWeight(.semibold)
    }

    var saveButton: some View {
        ZStack(alignment: .center) {
            Button {
                if let avatar {
                    isLoading = true
                    Task {
                        await onSave(avatar.updating { $0.altText = altText })
                        isLoading = false
                    }
                }
            } label: {
                Button("Save") {}
            }
            .buttonStyle(ActionButtonStyle(style: .primary))
            .disabled(isLoading)

            if isLoading {
                ProgressView()
            }
        }
    }

    var cancelButton: some View {
        Button(action: {
            focused = false
            onCancel()
        }) {
            Text("Cancel")
        }
        .buttonStyle(ActionButtonStyle(style: .secondary))
        .disabled(isLoading)
    }

    var actionButtons: some View {
        HStack() {
            Spacer()
            cancelButton

            saveButton
        }
    }

    var characterCountText: some View {
        Text("\(Constants.characterLimit - altText.count)")
            .font(.footnote)
            .monospacedDigit()
            .foregroundColor(altText.count >= Constants.characterLimit ? .red : .secondary)
            .padding(.trailing, 4)
    }

    var imageView: some View {
        AvatarView(
            url: avatar?.url,
            placeholderView: { avatar?.localImage?.resizable() },
            loadingView: {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        )
        .scaledToFill()
        .frame(width: Constants.imageSize, height: Constants.imageSize)
        .background(Color(UIColor.secondarySystemBackground))
        .aspectRatio(1, contentMode: .fill)
        .shape(RoundedRectangle(cornerRadius: 6))
    }
}

struct ActionButtonStyle: ButtonStyle {
    enum Style {
        case primary
        case secondary
    }
    let style: Style

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(style == .primary ? Color.primary: Color(uiColor: .quaternaryLabel))
            .foregroundStyle(style == .primary ? Color(uiColor: .systemBackground) : Color.primary)
            .clipShape(.capsule)
    }
}

extension AltTextEditorView {
    fileprivate enum Localized {
        static let pageTitle = NSLocalizedString(
            "AltText.Editor.title",
            value: "Alternative (ALT) Text",
            comment: "The title of Alt Text editor screen."
        )
        static let altTextPlaceholder = NSLocalizedString(
            "AltText.Editor.placeholder",
            value: "Write alt text...",
            comment: "Placeholder text for Alt Text editor text field."
        )
        static let saveButtonTitle = NSLocalizedString(
            "AltText.Editor.saveButtonTitle",
            value: "Save",
            comment: "Title for Save button."
        )
        static let cancelButtonTitle = NSLocalizedString(
            "AltText.Editor.cancelButtonTitle",
            value: "Cancel",
            comment: "Title for Cancel button."
        )
    }
}

extension AltTextEditorView {
    enum Constants {
        fileprivate static let imageSize: CGFloat = 88
        fileprivate static let minLength: CGFloat = 150
        fileprivate static let minAccessibilityLength: CGFloat = 200
        fileprivate static let characterLimit: Int = 100
    }
}

extension String {
    fileprivate var normalizedAltText: String {
        String(self.prefix(AltTextEditorView.Constants.characterLimit))
            .replacingOccurrences(of: "\n", with: "")
    }
}

private struct AltTextPresentationModifier: ViewModifier {
    @Binding var avatarModel: AvatarImageModel?
    let onSave: (AvatarImageModel) async -> Void
    let onCancel: () -> Void

    @EnvironmentObject var overlayManaegr: OverlayManager

    func body(content: Content) -> some View {
        ZStack {
            content
            if let avatarModel {
                Color.black.opacity(0.4).frame(maxWidth: .infinity)
                    .transition(.opacity)
                    .onTapGesture {
                        self.avatarModel = nil
                    }
                AltTextEditorView(avatar: avatarModel, onSave: onSave, onCancel: onCancel)
            }
        }
        .animation(.snappy, value: self.avatarModel != nil)
    }
}

extension View {
    func altTextEditor(
        avatarModel: Binding<AvatarImageModel?>,
        onSave: @escaping (AvatarImageModel) async -> Void
    ) -> some View {
        self.modifier(
            AltTextPresentationModifier(
                avatarModel: avatarModel,
                onSave: onSave,
                onCancel: {
                    avatarModel.wrappedValue = nil
                }
            )
        )
    }
}

#Preview {
    struct AltTextPreview: View {
        @State var text = ""
        let avatar = AvatarImageModel.preview_init(
            id: "1",
            source: .remote(url: "https://gravatar.com/userimage/110207384/1.jpeg?size=256")
        )

        var body: some View {
            NavigationView {
                VStack {
                    Text("Hellow world")
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.red)
            }
            .altTextEditor(avatarModel: .constant(avatar)) { _ in

            }
        }
    }

    return AltTextPreview()
}

final class OverlayManager: ObservableObject {
    @Published var isPresented: Bool = false
    @Published var content: AnyView? = nil

    func present<Content: View>(@ViewBuilder content: @escaping () -> Content) {
        self.content = AnyView(content())
        self.isPresented = true
    }

    func dismiss() {
        self.isPresented = false
        self.content = nil
    }
}
