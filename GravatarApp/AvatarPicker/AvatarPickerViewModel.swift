import Combine
import Foundation
import Gravatar
import SwiftUI

@MainActor
class AvatarPickerViewModel: ObservableObject {
    private let profileService: Gravatar.ProfileService
    private let avatarService: AvatarService
    private let imageDownloader: ImageDownloader

    private var avatarSelectionTask: Task<AvatarDetails?, Never>?

    private let toastManager: ToastManager

    private var selectedAvatarResult: Result<String, Error>? {
        didSet {
            if selectedAvatarResult?.value() != nil {
                updateSelectedAvatarURL()
            }
        }
    }

    private var networkMonitor: any NetworkMonitor
    let userSession: UserSession

    @Published var selectedAvatarURL: URL?
    @Published private(set) var backendSelectedAvatarURL: URL?
    @Published private(set) var gridResponseStatus: Result<Void, Error>?
    @Published private(set) var grid: AvatarGridModel = .init(avatars: [])

    @Published private(set) var isAvatarsLoading: Bool = false
    @Published var forceRefreshAvatar: Bool = false
    @Published var profileHash: String

    @Published var shouldDisplayNoSelectedAvatarWarning: Bool = false
    private(set) var connectivityRefreshTask: Task<Void, Never>? // for unit testing
    private var cancellables = Set<AnyCancellable>()

    init(
        userSession: UserSession,
        profileService: Gravatar.ProfileService? = nil,
        avatarService: AvatarService? = nil,
        imageDownloader: ImageDownloader? = nil,
        networkMonitor: any NetworkMonitor = SystemNetworkMonitor.shared,
        urlSession: URLSessionProtocol = GravatarURLSession.shared,
        toastManager: ToastManager = ToastManager()
    ) {
        self.userSession = userSession
        self.profileService = profileService ?? Gravatar.ProfileService(urlSession: urlSession)
        self.avatarService = avatarService ?? AvatarService(urlSession: urlSession)
        self.imageDownloader = imageDownloader ?? ImageDownloadService(urlSession: urlSession)
        self.networkMonitor = networkMonitor
        self.profileHash = userSession.profile.hash
        self.toastManager = toastManager

        setupCombine()
    }

    #if DEBUG
    static func preview_init(avatars: [AvatarImageModel] = []) -> AvatarPickerViewModel {
        let model = AvatarPickerViewModel(userSession: UserSession(profile: .testProfile, accessToken: "", context: .testContext))
        model.grid = .init(avatars: avatars, selectedAvatar: avatars.first(where: { $0.isSelected }))
        model.setupCombine()
        return model
    }
    #endif

    private func setupCombine() {
        grid.$avatars
            .map {
                $0.filter { avatar in
                    avatar.state == .loaded
                }.count
            }
            .combineLatest($selectedAvatarURL)
            .map { loadedAvatarCount, selectedAvatarURL in
                // Determine if the warning should be displayed
                selectedAvatarURL == nil && loadedAvatarCount > 0
            }
            .sink { [weak self] shouldShowWarning in
                withAnimation(.snappy) {
                    self?.shouldDisplayNoSelectedAvatarWarning = shouldShowWarning
                }
            }
            .store(in: &cancellables)

        $selectedAvatarURL
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.forceRefreshAvatar = true
            }
            .store(in: &cancellables)

        networkMonitor.hasNetworkConnection.dropFirst().sink { [weak self] newValue in
            if newValue && self?.gridResponseStatus?.error() != nil {
                self?.connectivityRefreshTask = Task {
                    await self?.fetchAvatars()
                }
            }
        }.store(in: &cancellables)
    }

    func selectAvatar(with id: String) async -> AvatarDetails? {
        guard
            grid.selectedAvatar?.id != id,
            grid.model(with: id)?.state == .loaded
        else { return nil }

        avatarSelectionTask?.cancel()

        avatarSelectionTask = Task {
            await postAvatarSelection(with: id, identifier: .hashID(userSession.profile.hash))
        }

        return await avatarSelectionTask?.value
    }

    func postAvatarSelection(with avatarID: String, identifier: ProfileIdentifier) async -> AvatarDetails? {
        defer {
            grid.setState(to: .loaded, onAvatarWithID: avatarID)
        }
        grid.selectAvatar(withID: avatarID)
        grid.setState(to: .loading, onAvatarWithID: avatarID)

        do {
            let selectedAvatar = try await profileService.setPublicAvatar(
                profileID: identifier,
                token: userSession.accessToken,
                imageID: avatarID
            )
            grid.replaceModel(withID: avatarID, with: .init(with: selectedAvatar))
            selectedAvatarResult = .success(selectedAvatar.imageID)
            return selectedAvatar
        } catch APIError.responseError(let reason) where reason.cancelled {
            // NoOp.
        } catch {
            grid.selectAvatar(withID: selectedAvatarResult?.value())
        }
        return nil
    }

    func fetchAvatars() async {
        defer {
            withAnimation(.smooth) {
                isAvatarsLoading = false
            }
        }
        guard userSession.accessToken.isEmpty == false else { return }
        do {
            isAvatarsLoading = true
            let images = try await profileService.fetchAvatars(
                profileID: .hashID(userSession.profile.hash),
                token: userSession.accessToken
            )
            withAnimation(.smooth) {
                grid.setAvatars(images.map(AvatarImageModel.init))
            }
            if let selectedAvatar = grid.selectedAvatar {
                selectedAvatarURL = selectedAvatar.url
                selectedAvatarResult = .success(selectedAvatar.id)
            }
            gridResponseStatus = .success(())
        } catch {
            gridResponseStatus = .failure(error)
        }
    }

    private func updateSelectedAvatarURL() {
        guard let selectedID = selectedAvatarResult?.value() else { return }
        grid.selectAvatar(withID: selectedID)
        selectedAvatarURL = grid.selectedAvatar?.url
    }

    func refresh() async {
        await fetchAvatars()
    }

    @discardableResult
    func update(altText: String, for avatar: AvatarImageModel) async -> Bool {
        do {
            let updatedAvatar = try await avatarService.updateAvatar(
                imageID: avatar.id,
                accessToken: userSession.accessToken,
                altText: altText
            )
            withAnimation {
                grid.replaceModel(withID: avatar.id, with: .init(with: updatedAvatar))
            }
            return true
        } catch APIError.responseError(reason: let reason) where reason.urlSessionErrorLocalizedDescription != nil {
            handleError(message: reason.urlSessionErrorLocalizedDescription ?? Localized.avatarAltTextError)
        } catch {
            handleError(message: Localized.avatarAltTextError)
        }

        func handleError(message: String) {}

        return false
    }

    func delete(_ avatar: AvatarImageModel) async -> Bool {
        let previouslySelectedAvatar = grid.selectedAvatar

        let deletedIndex = withAnimation {
            grid.deleteModel(avatar.id)
        }

        guard let deletedIndex else { return false }

        return await postDeletion(
            of: avatar,
            token: userSession.accessToken,
            deletingAvatarIndex: deletedIndex,
            previouslySelectedAvatar: previouslySelectedAvatar
        )
    }

    private func postDeletion(
        of avatar: AvatarImageModel,
        token: String,
        deletingAvatarIndex: Int,
        previouslySelectedAvatar: AvatarImageModel?
    ) async -> Bool {
        do {
            try await avatarService.delete(imageID: avatar.id, accessToken: token)
            selectedAvatarURL = grid.selectedAvatar?.url
            return true
        } catch APIError.responseError(let reason) where reason.httpStatusCode == 404 {
            selectedAvatarURL = grid.selectedAvatar?.url
            return true // no-op. We delete a not-found avatar from the UI.
        } catch APIError.responseError(reason: let reason) where reason.urlSessionErrorLocalizedDescription != nil {
            handleError(message: reason.urlSessionErrorLocalizedDescription ?? Localized.avatarDeletionError)
        } catch {
            handleError(message: Localized.avatarDeletionError)
        }
        return false

        func handleError(message: String) {
            withAnimation {
                grid.insert(avatar, at: deletingAvatarIndex)
                grid.selectAvatar(previouslySelectedAvatar)
                selectedAvatarURL = previouslySelectedAvatar?.url
            }
        }
    }

    func upload(_ image: UIImage) async {
        // SwiftUI doesn't update the UI if the grid is empty.
        // objectWillChange forces the update.
        objectWillChange.send()

        let localID = UUID().uuidString

        let localImageModel = AvatarImageModel(id: localID, source: .local(image: image), state: .loading, isSelected: false, altText: "")
        grid.append(localImageModel)

        await doUpload(squareImage: image, localID: localID, accessToken: userSession.accessToken)
    }

    func retryUpload(of localID: String) async {
        guard
            let model = grid.avatars.first(where: { $0.id == localID }),
            let localImage = model.localUIImage
        else {
            return
        }
        grid.setState(to: .loading, onAvatarWithID: localID)
        await doUpload(squareImage: localImage, localID: localID, accessToken: userSession.accessToken)
    }

    func deleteFailed(_ id: String) {
        withAnimation {
            _ = grid.deleteModel(id)
        }
    }

    private func doUpload(squareImage: UIImage, localID: String, accessToken: String) async {
        do {
            let avatar = try await avatarService.upload(
                squareImage,
                selectionPolicy: .selectUploadedImageIfNoneSelected(for: .hashID(HashID(userSession.profile.hash))),
                accessToken: accessToken
            )

            ImageCache.shared.setEntry(.ready(squareImage), for: avatar.imageURL)

            let newModel = AvatarImageModel(with: avatar)
            grid.replaceModel(withID: localID, with: newModel)

            if avatar.isSelected {
                grid.selectAvatar(withID: avatar.imageID)
                self.selectedAvatarURL = URL(string: avatar.imageURL)
                self.backendSelectedAvatarURL = URL(string: avatar.imageURL)
            }
        } catch ImageUploadError.responseError(reason: let .invalidHTTPStatusCode(response, errorPayload))
            where response.statusCode == HTTPStatus.badRequest.rawValue || response.statusCode == HTTPStatus.payloadTooLarge.rawValue
        {
            let message: String = {
                if response.statusCode == HTTPStatus.payloadTooLarge.rawValue {
                    // The error response comes back as an HTML document for 413, which is unexpected.
                    // Until BE starts to send the json, we'll handle 413 on the client side.
                    return Localized.imageTooBigError
                }
                return errorPayload?.message ?? Localized.genericUploadError
            }()
            // If the status code is 400 then it means we got a validation error about this image and the operation is not suitable for retrying.
            handleUploadError(
                imageID: localID,
                squareImage: squareImage,
                supportsRetry: false,
                errorMessage: message
            )
        } catch ImageUploadError.responseError(reason: let .invalidHTTPStatusCode(response, errorPayload))
            where response.statusCode == HTTPStatus.unauthorized.rawValue
        {
            // If the status code is 401 (unauthorized), then it means the token is not valid and we should prompt the user accordingly.
            handleUnrecoverableClientError(APIError.responseError(reason: .invalidHTTPStatusCode(response: response, errorPayload: errorPayload)))
        } catch ImageUploadError.responseError(reason: let reason) where reason.urlSessionErrorLocalizedDescription != nil {
            handleUploadError(
                imageID: localID,
                squareImage: squareImage,
                supportsRetry: true,
                errorMessage: reason.urlSessionErrorLocalizedDescription ?? Localized.genericUploadError
            )
        } catch {
            handleUploadError(
                imageID: localID,
                squareImage: squareImage,
                supportsRetry: true,
                errorMessage: Localized.genericUploadError
            )
        }
    }

    private func handleUploadError(imageID: String, squareImage: UIImage, supportsRetry: Bool, errorMessage: String) {
        let storedModel = grid.model(with: imageID)
        let newModel = AvatarImageModel(
            id: imageID,
            source: .local(image: squareImage),
            state: .error(supportsRetry: supportsRetry, errorMessage: errorMessage),
            isSelected: false,
            altText: storedModel?.altText ?? ""
        )
        grid.replaceModel(withID: imageID, with: newModel)
    }

    private func handleUnrecoverableClientError(_ error: Error) {
        self.grid.setAvatars([])
        self.gridResponseStatus = .failure(error)
    }
}

// MARK: - Download image to file

extension AvatarPickerViewModel {
    func fetchAndSaveToFile(avatar: AvatarImageModel) async -> URL? {
        guard let image = await fetchOriginalSizeAvatar(for: avatar) else { return nil }
        do {
            return try image.saveToFile()
        } catch {
            toastManager.showToast(Localized.avatarShareFail, type: .error)
        }
        return nil
    }

    private func fetchOriginalSizeAvatar(for avatar: AvatarImageModel) async -> UIImage? {
        guard let avatarURL = avatar.shareURL else { return nil }
        do {
            grid.setState(to: .loading, onAvatarWithID: avatar.id)
            let result = try await imageDownloader.fetchImage(with: avatarURL, forceRefresh: false, processingMethod: .common())
            grid.setState(to: .loaded, onAvatarWithID: avatar.id)
            return result.image
        } catch ImageFetchingError.responseError(reason: let reason) where reason.urlSessionErrorLocalizedDescription != nil {
            grid.setState(to: .loaded, onAvatarWithID: avatar.id)
            toastManager.showToast(reason.urlSessionErrorLocalizedDescription ?? Localized.avatarShareFail, type: .error)
        } catch {
            grid.setState(to: .loaded, onAvatarWithID: avatar.id)
            toastManager.showToast(Localized.avatarShareFail, type: .error)
        }
        return nil
    }
}

extension AvatarPickerViewModel {
    private enum Localized {
        static let genericUploadError = NSLocalizedString(
            "AvatarPickerViewModel.Upload.Error.message",
            value: "Oops, there was an error uploading the image.",
            comment: "A generic error message to show on an error dialog when the upload fails."
        )
        static let avatarUpdateSuccess = NSLocalizedString(
            "AvatarPickerViewModel.Update.Success",
            value: "Avatar updated! It may take a few minutes to appear everywhere.",
            comment: "This confirmation message shows when the user picks a different avatar."
        )
        static let profileUpdateSuccess = NSLocalizedString(
            "Profile.Update.Success",
            value: "Profile updated successfully",
            comment: "This confirmation message shows when the user updates fields of their profile."
        )
        static let avatarUpdateFail = NSLocalizedString(
            "AvatarPickerViewModel.Update.Fail",
            value: "Oops, something didn't quite work out while trying to change your avatar.",
            comment: "This error message shows when the user attempts to pick a different avatar and fails."
        )
        static let profileUpdateFail = NSLocalizedString(
            "Profile.Update.Fail",
            value: "Oops, something didn't quite work out while trying to update your profile.",
            comment: "This error message shows when the user attempts to update fields of their profile and it fails."
        )
        static let imageTooBigError = NSLocalizedString(
            "AvatarPicker.Upload.Error.ImageTooBig.Error",
            value: "The provided image exceeds the maximum size: 10MB",
            comment: "Error message to show when the upload fails because the image is too big."
        )
        static let avatarDeletionError = NSLocalizedString(
            "AvatarPickerViewModel.Delete.Error",
            value: "Oops, there was an error deleting the image.",
            comment: "This error message shows when the user attempts to delete an avatar and fails."
        )
        static let avatarShareFail = NSLocalizedString(
            "AvatarPickerViewModel.Share.Fail",
            value: "Oops, something didn't quite work out while trying to share your avatar.",
            comment: "This error message shows when the user attempts to share an avatar and fails."
        )
        static let avatarAltTextSuccess = NSLocalizedString(
            "AvatarPickerViewModel.AltText.Success",
            value: "Image alt text was changed successfully.",
            comment: "This confirmation message shows when the user has updated the alt text."
        )
        static let avatarAltTextError = NSLocalizedString(
            "AvatarPickerViewModel.AltText.Error",
            value: "Oops, something didn't quite work out while trying to update the alt text.",
            comment: "This error message shows when the user attempts to change the alt text of an avatar and fails."
        )
        static let avatarRatingUpdateSuccess = NSLocalizedString(
            "AvatarPickerViewModel.RatingUpdate.Success",
            value: "Avatar rating was changed successfully.",
            comment: "This confirmation message shows when the user picks a different avatar rating and the change was applied successfully."
        )
        static let avatarRatingError = NSLocalizedString(
            "AvatarPickerViewModel.Rating.Error",
            value: "Oops, something didn't quite work out while trying to rate your avatar.",
            comment: "This error message shows when the user attempts to change the rating of an avatar and fails."
        )
    }
}
