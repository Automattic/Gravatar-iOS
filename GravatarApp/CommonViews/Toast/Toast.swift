import Gravatar
import SwiftUI

struct Toast: View {
    private enum Constants {
        static let backgroundColor = UIColor(light: .label, dark: .rgba(225, 225, 225))
    }

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    private(set) var toast: ToastItem
    private(set) var dismissHandler: (ToastItem) -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text(toast.message)
                .font(.footnote)
            Spacer(minLength: .DS.Padding.double)
            Button {
                dismissHandler(toast)
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 12, height: 12)
            }
        }
        .padding(.horizontal, .DS.Padding.double)
        .padding(.vertical, .DS.Padding.split)
        .background(backgroundColor)
        .cornerRadius(4)
        .foregroundColor(foregroundColor)
        .if(toast.shouldShowShadow, transform: { view in
            view.shadow(radius: 3, y: 3)
        })
        .zIndex(1)
    }

    var backgroundColor: Color {
        Color(Constants.backgroundColor)
    }

    var foregroundColor: Color {
        Color(UIColor.systemBackground)
    }
}

#Preview {
    VStack {
        Toast(toast: .init(
            message: "Info message!",
            type: .info,
            stackingBehavior: .avoidStackingWithSameMessage
        )) { _ in
        }

        Toast(toast: .init(
            message: "Error message!",
            type: .error,
            stackingBehavior: .alwaysStack
        )) { _ in
        }
    }
    .padding()
}
