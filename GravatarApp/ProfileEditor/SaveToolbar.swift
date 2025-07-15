import SwiftUI

struct SaveToolbar: View {
    @ObservedObject var viewModel: EditProfileViewModel

    var body: some View {
        HStack {
            if viewModel.isSaving {
                Text(ProfileEditLocalization.savingLabelText).font(.headline)
                Spacer()
                // Hidden button to keep the same toolbar height
                Button {} label: { Text("hidden") }
                    .buttonStyle(.actionButton(style: .primary))
                    .opacity(0)
            } else {
                Button {
                    viewModel.removeUnsavedChanges()
                } label: {
                    Text(ProfileEditLocalization.cancelButtonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.actionButton(style: .secondary))

                Button {
                    Task {
                        await viewModel.save()
                    }
                } label: {
                    Text(ProfileEditLocalization.saveButtonTitle)
                        .frame(maxWidth: .infinity)
                }
                .environment(\.colorScheme, .light)
                .buttonStyle(.actionButton())
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .environment(\.colorScheme, .dark)
        .background(Color.DS.bluishColor)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#if DEBUG
#Preview {
    SaveToolbar(viewModel: EditProfileViewModel(userSession: UserSession(
        profile: .testProfile,
        accessToken: "",
        context: .testContext
    )))
}
#endif
