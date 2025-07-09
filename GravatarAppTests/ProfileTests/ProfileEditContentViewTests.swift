import Foundation
@testable import GravatarApp
import SnapshotTesting
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct ProfileEditContentViewTests {
    @MainActor
    @Test
    func profileEditContentViewIntrinsicHeight() async throws {
        let editProfileViewModel: EditProfileViewModel = .init(
            userSession: .init(profile: .full, accessToken: "testToken", context: .testContext),
            urlSession: URLSessionMock()
        )
        let view = ProfileEditContentView(viewModel: editProfileViewModel)
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }
}
