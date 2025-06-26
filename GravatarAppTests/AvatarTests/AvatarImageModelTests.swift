
@testable import GravatarApp
import Testing

struct AvatarImageModelTests {
    @Test("Check URL exists")
    func uRLExists() async throws {
        let imageURL = "https://example.com/avatar.jpg"
        let model = AvatarImageModel.preview_init(id: "someID", source: .remote(url: imageURL))
        #expect(model.url?.absoluteString == imageURL)
        #expect(model.localImage == nil)
    }

    @Test("Check local image exists")
    func localImageExists() async throws {
        let model = AvatarImageModel.preview_init(id: "someID", source: .local(image: ImageHelper.testImage))
        #expect(model.localImage != nil)
        #expect(model.localUIImage != nil)
        #expect(model.url == nil)
    }

    @Test("Check state change from loading to loaded")
    func stateChangeLoadingLoaded() async throws {
        let model = AvatarImageModel.preview_init(id: "someID", source: .local(image: ImageHelper.testImage), state: .loading)
        #expect(model.state == .loading)

        let loadedModel = model.updating { $0.state = .loaded }
        #expect(loadedModel.state == .loaded, "The state should be .loaded")
    }

    @Test("Check state change from loading to error")
    func stateChangeLoadingError() async throws {
        let model = AvatarImageModel.preview_init(id: "someID", source: .local(image: ImageHelper.testImage), state: .loading)
        #expect(model.state == .loading)

        let loadedModel = model.updating { $0.state = .error(supportsRetry: true, errorMessage: "Some Error") }
        switch loadedModel.state {
        case .error:
            #expect(Bool(true))
        default: #expect(Bool(false), "The state should be .error")
        }
    }

    @Test("Test changing all avatar properties")
    func avatarPropertiesChanges() {
        let model = AvatarImageModel(id: "id", source: .remote(url: ""), state: .loaded, isSelected: true, altText: "")
        let newID = "NewID"
        let newAltText = "NewAltText"

        let updatedModel = model.updating {
            $0.id = newID
            $0.source = .local(image: ImageHelper.testImage)
            $0.state = .loading
            $0.isSelected = false
            $0.altText = newAltText
        }

        #expect(updatedModel.id == newID)
        #expect(updatedModel.state == .loading)
        #expect(updatedModel.isSelected == false)
        #expect(updatedModel.altText == newAltText)

        switch updatedModel.source {
        case .local:
            #expect(Bool(true))
        default:
            #expect(Bool(false), "The source should be .local")
        }
    }

    @Test("Test changing one avatar property won't affect others")
    func avatarPropertiyChange() {
        let id = "id"
        let altText = "altText"

        let model = AvatarImageModel(id: id, source: .remote(url: ""), state: .loaded, isSelected: true, altText: altText)

        let updatedModel = model.updating {
            $0.isSelected = false
        }

        #expect(updatedModel.id == id)
        #expect(updatedModel.state == .loaded)
        #expect(updatedModel.isSelected == false)
        #expect(updatedModel.altText == altText)

        switch updatedModel.source {
        case .remote:
            #expect(Bool(true))
        default:
            #expect(Bool(false), "The source should be .remote")
        }
    }
}

extension AvatarImageModel {
    /// This is meant to be used in previews and unit tests only.
    static func preview_init(id: String, source: Source, state: State = .loaded, isSelected: Bool = false) -> Self {
        AvatarImageModel(id: id, source: source, state: state, isSelected: isSelected, altText: "")
    }
}
