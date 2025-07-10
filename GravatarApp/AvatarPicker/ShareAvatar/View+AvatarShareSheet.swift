import SwiftUI

extension View {
    func avatarShareSheet(item: Binding<AvatarShareItem?>) -> some View {
        self.sheet(item: item) { avatarShareItem in
            ShareSheet(items: [avatarShareItem.fileURL])
                .presentationDetents([.medium, .large])
        }
    }
}
