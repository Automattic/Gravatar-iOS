import Foundation
@testable import GravatarApp
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
@MainActor
struct WelcomeViewTests {
    let viewModel = WelcomeViewModel(userDefaults: UserDefaults(suiteName: "tests")!, context: .testContext)

    @Test("Welcome view clean state")
    @MainActor
    func welcomeView() async throws {
        let view = WelcomeView(viewModel: viewModel)
            .frame(width: ViewImageConfig.iPhone13.size?.width ?? 0, height: ViewImageConfig.iPhone13.size?.height ?? 0)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @Test("Welcome view with profile error state")
    @MainActor
    func welcomeViewProfileError() async throws {
        let view = WelcomeView(viewModel: viewModel).fullScreenFrame()

        viewModel.profileFetchingError = .responseError(reason: .unexpected(NSError(domain: "", code: 1)))

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @Test("Welcome view with OAuth denied error state")
    @MainActor
    func welcomeViewOAuthError() async throws {
        let view = WelcomeView(viewModel: viewModel).fullScreenFrame()

        viewModel.oauthError = .accessDenied

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @Test("Welcome view with OAuth request error state")
    @MainActor
    func welcomeViewOAuthRequestError() async throws {
        let view = WelcomeView(viewModel: viewModel).fullScreenFrame()

        viewModel.oauthError = .tokenRequestError(.init(.secureConnectionFailed, userInfo: [
            NSLocalizedDescriptionKey: "Unable to establish a secure SSL connection with the server.",
        ]))

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }
}

extension View {
    func fullScreenFrame() -> some View {
        self.frame(width: ViewImageConfig.iPhone13.size?.width ?? 0, height: ViewImageConfig.iPhone13.size?.height ?? 0)
    }
}
