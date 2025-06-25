import Analytics
import Gravatar
import SwiftUI

struct AvatarPickerView: View {

    let onLogout: () -> Void
    @StateObject var avatarPickerModel: AvatarPickerViewModel

    init(avatarPickerModel: AvatarPickerViewModel, onLogout: @escaping () -> Void) {
        self._avatarPickerModel = StateObject(wrappedValue: avatarPickerModel)
        self.onLogout = onLogout
    }

    var body: some View {
        VStack(spacing: 0) {
            AvatarPickerHeaderView(profile: $avatarPickerModel.profile)
            ScrollView {
                VStack(spacing: 0) {
                    AvatarGrid(grid: avatarPickerModel.grid) { avatar in

                    } onAvatarActionTap: { avatar, action in

                    } onFailedUploadTapped: { error in

                    }
                }
                .padding()
            }
        }
        .ignoresSafeArea(.container, edges: .top)
    }

    func profileView(with profile: Profile) -> some View {
        Text(profile.displayName)
    }
}

//#Preview {
//    AvatarPickerView(profile: .testProfile, onLogout: {})
//}
