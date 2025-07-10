import Combine
import Foundation
@testable import GravatarApp
import GravatarUI
import Testing

@MainActor
final class AvatarPickerViewModelTests {
    var cancellables = Set<AnyCancellable>()
    var model: AvatarPickerViewModel

    init() {
        model = Self.createModel()
    }

    static func createModel(
        session: URLSessionProtocol = URLSessionMock(),
        imageDownloader: ImageDownloader = TestImageDownloader(result: .success),
        networkMonitor: TestNetworkMonitor? = nil
    ) -> AvatarPickerViewModel {
        AvatarPickerViewModel(
            userSession: UserSession(profile: .testProfile, accessToken: "token", context: .testContext),
            profileService: ProfileService(urlSession: session),
            avatarService: AvatarService(urlSession: session),
            imageDownloader: imageDownloader,
            networkMonitor: networkMonitor ?? TestNetworkMonitor(),
            disableAnimations: true
        )
    }

    static func createImageModel(id: String, source: AvatarImageModel.Source, isSelected: Bool = false) -> AvatarImageModel {
        AvatarImageModel(
            id: id,
            source: source,
            state: .loaded,
            isSelected: isSelected,
            altText: "fake alt text"
        )
    }

    @Test
    func firstAvatarsAreLoaded() async throws {
        await confirmation { confirmation in
            model.grid.$avatars.dropFirst().sink { avatarModels in
                #expect(avatarModels.count == 5)
                confirmation.confirm()
            }.store(in: &cancellables)

            await model.refresh()
        }
    }

    @Test(arguments: [AvatarImageModel.State.loading, .loaded])
    func testShouldDisplayNoSelectedAvatarWarning(state: AvatarImageModel.State) async throws {
        let model = AvatarPickerViewModel.preview_init(avatars: [
            .init(id: "123", source: .remote(url: "https://example.com"), state: state, isSelected: false, altText: ""),
        ])
        #expect(model.shouldDisplayNoSelectedAvatarWarning == (state == .loaded))
    }

    @Test
    func shouldDisplayNoSelectedAvatarWarningForLoaded() async throws {
        let model = AvatarPickerViewModel.preview_init(avatars: [
            .init(id: "123", source: .remote(url: "https://example.com"), state: .loaded, isSelected: false, altText: ""),
        ])
        #expect(model.shouldDisplayNoSelectedAvatarWarning == true)
    }

    @Test
    func testSelectAvatar() async throws {
        let toSelectID = "9862792c565394..."
        await model.refresh()
        await confirmation { confirmation in
            // First selectedAvatar change after setting the initial status.
            // Second selectedAvatar change is local set before the request.
            // Third selectedAvatar change is after the request, and the one we are interested in.
            model.grid.$selectedAvatar.dropFirst(2).sink { selected in
                #expect(selected?.isSelected == true)
                #expect(selected?.id == toSelectID)
                confirmation.confirm()
            }.store(in: &cancellables)
            let selected = await model.selectAvatar(with: toSelectID)
            #expect(selected?.imageID == toSelectID)
        }
    }

    @Test
    func selectAvatarFailNoInternet() async throws {
        let toSelectID = "9862792c565394"
        let model = Self.createModel(session: URLSessionMock(shouldSimulateNoNetworkConnection: true))
        model.grid.setAvatars([Self.createImageModel(id: toSelectID, source: .remote(url: ""))])

        await confirmation(expectedCount: 1) { confirmation in
            let avatar = await model.selectAvatar(with: toSelectID)
            #expect(avatar == nil)
            confirmation.confirm()
        }
    }

    @Test
    func selectAvatarFailInvalidHTTPStatusCode() async throws {
        let toSelectID = "9862792c565394"
        let model = Self.createModel(session: URLSessionMock(returnErrorCode: 400))
        model.grid.setAvatars([Self.createImageModel(id: toSelectID, source: .remote(url: ""))])

        await confirmation(expectedCount: 1) { confirmation in
            let avatar = await model.selectAvatar(with: toSelectID)
            #expect(avatar == nil)
            confirmation.confirm()
        }
    }

    @Test
    func deleteAvatar() async throws {
        await model.refresh()
        let avatarToDelete = model.grid.avatars.last!
        #expect(await model.delete(avatarToDelete), "Avatar deletion should be successfull")
        #expect(model.grid.index(of: avatarToDelete.id) == nil, "Deleted avatar should not be on the grid")
    }

    @Test
    func deletingNonExistentAvatarFails() async throws {
        await model.refresh()
        let avatarToDelete = Self.createImageModel(id: "someID", source: .remote(url: ""))
        #expect(await model.delete(avatarToDelete) == false, "Avatar deletion should not succeed")
    }

    @Test
    func deleteSelectedAvatar() async throws {
        await model.refresh()
        let selectedAvatar = model.grid.selectedAvatar!

        await confirmation { confirmation in
            model.$selectedAvatarURL.dropFirst(1).sink { url in
                #expect(url == nil)
                confirmation.confirm()
            }.store(in: &cancellables)

            #expect(await model.delete(selectedAvatar))
        }

        #expect(model.grid.selectedAvatar == nil)
        #expect(model.selectedAvatarURL == nil)
        #expect(model.shouldDisplayNoSelectedAvatarWarning == true)
    }

    @Test("Test success deletion when the response is a 404 error")
    func deleteError404() async throws {
        let avatarToDelete = Self.createImageModel(id: "1", source: .remote(url: ""))
        model = Self.createModel(session: URLSessionMock(returnErrorCode: HTTPStatus.notFound.rawValue))
        model.grid.setAvatars([avatarToDelete])

        #expect(await model.delete(avatarToDelete))
        #expect(model.grid.index(of: avatarToDelete.id) == nil)
    }

    @Test("Test success deletion of selected avatar when the response is a 404 error")
    func deleteSelectedAvatarError404() async throws {
        let avatarToDelete = Self.createImageModel(id: "1", source: .remote(url: ""), isSelected: true)
        model = Self.createModel(session: URLSessionMock(returnErrorCode: HTTPStatus.notFound.rawValue))
        model.grid.setAvatars([avatarToDelete])
        #expect(model.grid.selectedAvatar != nil)

        await confirmation { confirmation in
            model.$selectedAvatarURL.dropFirst(1).sink { url in
                #expect(url == nil)
                confirmation.confirm()
            }.store(in: &cancellables)

            #expect(await model.delete(avatarToDelete))
        }

        #expect(model.grid.selectedAvatar == nil)
        #expect(model.selectedAvatarURL == nil)
        #expect(model.grid.index(of: avatarToDelete.id) == nil)
    }

    @Test("Test error deletion when the response is an error different to 404")
    func deleteErrorFails() async throws {
        let avatarToDelete = Self.createImageModel(id: "1", source: .remote(url: ""))
        model = Self.createModel(session: URLSessionMock(returnErrorCode: HTTPStatus.unauthorized.rawValue))
        model.grid.setAvatars([avatarToDelete])

        #expect(await model.delete(avatarToDelete) == false, "Delete request should fail")
        #expect(model.grid.index(of: avatarToDelete.id) != nil, "Deleting avatar should not have been deleted")
    }

    @Test
    func updateAltText() async throws {
        let newAltText = "Updated Alt Text"
        await model.refresh()
        let avatar = model.grid.avatars[0]
        let success = await model.update(altText: newAltText, for: avatar)

        #expect(success)

        let updatedAvatar = model.grid.avatars[0]
        #expect(updatedAvatar.altText == newAltText)
    }

    @Test(
        "Handle avatar alt text change: Failure",
        arguments: [HTTPStatus.unauthorized, .forbidden]
    )
    func updateAltTextError(httpStatus: HTTPStatus) async throws {
        model = Self.createModel(session: URLSessionMock(returnErrorCode: httpStatus.rawValue))
        model.grid.setAvatars([Self.createImageModel(id: "1", source: .remote(url: ""))])
        let avatar = model.grid.avatars[0]
        let originalAltText = avatar.altText

        let updatedAvatar = model.grid.avatars[0]
        #expect(updatedAvatar.altText == originalAltText, "Alt text should not have changed")
    }

    @Test("Test reload after connectivity reconnection")
    func reloadAfterReconnection() async throws {
        let networkMonitor = TestNetworkMonitor()
        networkMonitor.isConnected = false
        let session = URLSessionMock(shouldSimulateNoNetworkConnection: true)

        let model = Self.createModel(session: session, networkMonitor: networkMonitor)
        await model.refresh()

        #expect(model.gridResponseStatus?.error() != nil)

        try await confirmation(expectedCount: 1) { @MainActor confirmation in
            model.$gridResponseStatus.dropFirst().sink { result in
                #expect(result?.error() == nil)
                #expect(result?.value() != nil)

                confirmation.confirm()
            }.store(in: &cancellables)

            session.shouldSimulateNoNetworkConnection = false
            networkMonitor.isConnected = true
            // Make the clock tick!
            try await Task.sleep(for: .milliseconds(10))
        }
    }

    @Test("Test avatar upload")
    func avatarUpload() async throws {
        #expect(model.grid.avatars.count == 0)
        let task = Task {
            await model.upload(ImageHelper.testImage)
        }

        try await Task.sleep(for: .milliseconds(0.1)) // execute task
        #expect(model.grid.avatars.count == 1)
        #expect(model.grid.avatars.first?.state == .loading)

        _ = await task.result

        #expect(model.grid.selectedAvatar?.state == .loaded)
    }

    @Test("Test avatar upload failed")
    func avatarUploadFailed() async throws {
        let urlSession = URLSessionMock(shouldSimulateNoNetworkConnection: true)
        model = Self.createModel(session: urlSession)

        #expect(model.grid.avatars.count == 0)

        await model.upload(ImageHelper.testImage)

        #expect(model.grid.avatars.count == 1)
        let avatar = model.grid.avatars.first!

        if case .error(let supportsRetry, let errorMessage) = avatar.state {
            #expect(supportsRetry == true)
            #expect(errorMessage.isEmpty == false)
        } else {
            Issue.record("Unexpected avatar state: \(avatar)")
        }
    }

    @Test("Test avatar upload retry")
    func avatarUploadRetry() async throws {
        let urlSession = URLSessionMock(shouldSimulateNoNetworkConnection: true)
        model = Self.createModel(session: urlSession)

        #expect(model.grid.avatars.count == 0)

        await model.upload(ImageHelper.testImage)

        #expect(model.grid.avatars.count == 1)
        let avatar = model.grid.avatars.first!

        switch avatar.state {
        case .loaded, .loading: Issue.record("Unexpected avatar state: \(avatar)")
        default: break // continue with error state
        }

        urlSession.shouldSimulateNoNetworkConnection = false

        await model.retryUpload(of: avatar.id)

        #expect(model.grid.selectedAvatar?.state == .loaded)
    }
}
