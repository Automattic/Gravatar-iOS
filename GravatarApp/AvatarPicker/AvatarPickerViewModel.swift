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
    private var authToken: String
    private var selectedAvatarResult: Result<String, Error>? {
        didSet {
            if selectedAvatarResult?.value() != nil {
                updateSelectedAvatarURL()
            }
        }
    }

    @Published var profile: Profile

    @Published var selectedAvatarURL: URL?
    @Published private(set) var backendSelectedAvatarURL: URL?
    @Published private(set) var gridResponseStatus: Result<Void, Error>?
    @Published private(set) var grid: AvatarGridModel = .init(avatars: [])

    @Published private(set) var isAvatarsLoading: Bool = false
    @Published var avatarIdentifier: AvatarIdentifier?
    @Published var forceRefreshAvatar: Bool = false


    @Published var shouldDisplayNoSelectedAvatarWarning: Bool = false

    private var cancellables = Set<AnyCancellable>()


    init(
        profile: Profile,
        authToken: String,
        profileService: Gravatar.ProfileService? = nil,
        avatarService: AvatarService? = nil,
        imageDownloader: ImageDownloader? = nil
    ) {
        self.profile = profile
        avatarIdentifier = .hashID(profile.hash)
        self.authToken = authToken
        self.profileService = profileService ?? Gravatar.ProfileService()
        self.avatarService = avatarService ?? AvatarService()
        self.imageDownloader = imageDownloader ?? ImageDownloadService()

        setupCombine()
    }

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
                self?.shouldDisplayNoSelectedAvatarWarning = shouldShowWarning
            }
            .store(in: &cancellables)
    }

    func selectAvatar(with id: String) async -> AvatarDetails? {
        guard
            grid.selectedAvatar?.id != id,
            grid.model(with: id)?.state == .loaded
        else { return nil }

        avatarSelectionTask?.cancel()

        avatarSelectionTask = Task {
            await postAvatarSelection(with: id, authToken: authToken, identifier: .hashID(profile.hash))
        }

        return await avatarSelectionTask?.value
    }

    func postAvatarSelection(with avatarID: String, authToken: String, identifier: ProfileIdentifier) async -> AvatarDetails? {
        defer {
            grid.setState(to: .loaded, onAvatarWithID: avatarID)
        }
        grid.selectAvatar(withID: avatarID)
        grid.setState(to: .loading, onAvatarWithID: avatarID)

        do {
            let selectedAvatar = try await profileService.setPublicAvatar(profileID: identifier, token: authToken, imageID: avatarID)
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
        do {
            isAvatarsLoading = true
            let images = try await profileService.fetchAvatars(profileID: .hashID(profile.hash), token: authToken)
            withAnimation {
                grid.setAvatars(images.map(AvatarImageModel.init))
            }
            if let selectedAvatar = grid.selectedAvatar {
                selectedAvatarURL = selectedAvatar.url
                selectedAvatarResult = .success(selectedAvatar.id)
            }
            isAvatarsLoading = false
            gridResponseStatus = .success(())
        } catch {
            gridResponseStatus = .failure(error)
            isAvatarsLoading = false
        }
    }

    func deleteFailed(_ id: String) {
        _ = grid.deleteModel(id)
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
            let updatedAvatar = try await avatarService.updateAvatar(imageID: avatar.id, accessToken: authToken, altText: altText)
            withAnimation {
                grid.replaceModel(withID: avatar.id, with: .init(with: updatedAvatar))
            }
            return true
        } catch APIError.responseError(reason: let reason) where reason.urlSessionErrorLocalizedDescription != nil {
            handleError(message: reason.urlSessionErrorLocalizedDescription ?? Localized.avatarAltTextError)
        } catch {
            handleError(message: Localized.avatarAltTextError)
        }

        func handleError(message: String) {

        }

        return false
    }

    func delete(_ avatar: AvatarImageModel) async -> Bool {
        defer {
            selectedAvatarURL = grid.selectedAvatar?.url
        }
        let previouslySelectedAvatar = grid.selectedAvatar

        let deletedIndex = withAnimation {
            grid.deleteModel(avatar.id)
        }

        guard let deletedIndex else { return false }

        if selectedAvatarURL != grid.selectedAvatar?.url {
            selectedAvatarURL = grid.selectedAvatar?.url
        }

        return await postDeletion(
            of: avatar,
            token: authToken,
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
            return true
        } catch APIError.responseError(let reason) where reason.httpStatusCode == 404 {
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
}

extension AvatarPickerViewModel {
    enum Localized {
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

extension Result<[AvatarImageModel], Error> {
    func isEmpty() -> Bool {
        switch self {
        case .success(let models):
            models.isEmpty
        default:
            false
        }
    }
}

extension CGFloat {
    enum DS {
        enum Padding {
            public static let half: CGFloat = 4
            public static let single: CGFloat = 8
            public static let split: CGFloat = 12
            public static let double: CGFloat = 16
            public static let medium: CGFloat = 24
            public static let large: CGFloat = 32
            public static let max: CGFloat = 48
        }
    }
}

extension AvatarImageModel {
    init(with avatar: AvatarDetails) {
        id = avatar.imageID
        let avatarGridItemSize = Int(AvatarGridConstants.maxAvatarWidth * UITraitCollection.current.displayScale)
        source = .remote(url: avatar.url(withSize: String(avatarGridItemSize)))
        state = .loaded
        isSelected = avatar.isSelected
        altText = avatar.altText
    }
}

extension Result {
    func value() -> Success? {
        switch self {
        case .success(let value):
            value
        default:
            nil
        }
    }
}

extension Result {
    func error() -> Error? {
        switch self {
        case .failure(let error):
            error
        default:
            nil
        }
    }
}

extension AvatarDetails {
    func url(withSize size: String) -> String {
        if let newURL = URLComponents(string: imageURL)?.replacingQueryItem(name: "size", value: size).string {
            return newURL
        }
        return imageURL
    }

    var isSelected: Bool {
        selected ?? false
    }
}

extension URLComponents {
    /// Replaces the query item if it exists, otherwise adds a new one.
    func replacingQueryItem(name: String, value: String?) -> URLComponents {
        var copy = self
        let newItem = URLQueryItem(name: name, value: value)

        if var queryItems = self.queryItems,
           let sizeItemIndex = queryItems.firstIndex(where: { $0.name == name })
        {
            // Replace the query item
            queryItems[sizeItemIndex] = newItem
            copy.queryItems = queryItems
        } else {
            // Add the query item if it doesn't exist
            copy.queryItems = (self.queryItems ?? []) + [newItem]
        }

        return copy
    }
}
