@testable import GravatarUI
import Testing

let initialAvatars: [AvatarImageModel] = [
    .preview_init(id: "0", source: .remote(url: "https://example.com/1.jpg")),
    .preview_init(id: "1", source: .remote(url: "https://example.com/1.jpg"), isSelected: true),
    .preview_init(id: "2", source: .remote(url: "https://example.com/1.jpg")),
    .preview_init(id: "3", source: .remote(url: "https://example.com/1.jpg")),
    .preview_init(id: "4", source: .remote(url: "https://example.com/1.jpg")),
]

let initiallySelectedAvatarID = "1"

struct AvatarGridModelTests {
    let model = AvatarGridModel(avatars: [])

    init() {
        model.setAvatars(initialAvatars)
    }

    @Test("Test initial selected avatar")
    func avatarGridModel() async throws {
        #expect(model.selectedAvatar?.id == initiallySelectedAvatarID)
    }

    @Test("Test append function")
    func avatarGridModelAppend() async throws {
        let appendedAvatar = AvatarImageModel.preview_init(id: "new", source: .remote(url: "https://example.com/1.jpg"))
        model.append(appendedAvatar)

        #expect(model.index(of: "new") == 0)
    }

    @Test("Test select function")
    func avatarGridModelSelect() async throws {
        #expect(model.selectedAvatar?.id == initiallySelectedAvatarID)

        model.selectAvatar(withID: "4")

        #expect(model.selectedAvatar?.id == "4")
    }

    @Test("Test select non-existent id won't change selection")
    func avatarGridModelSelectFail() async throws {
        #expect(model.selectedAvatar?.id == initiallySelectedAvatarID)

        model.selectAvatar(withID: "non_existing")

        #expect(model.selectedAvatar?.id == initiallySelectedAvatarID)
    }

    @Test("Test select nil will unselect selection")
    func avatarGridModelSelectNil() async throws {
        #expect(model.selectedAvatar?.id == initiallySelectedAvatarID)

        model.selectAvatar(withID: nil)

        #expect(model.selectedAvatar?.id == nil)
    }

    @Test("Test indexOf function")
    func avatarGridModelIndexOf() async throws {
        #expect(model.index(of: "3") == 3)
        #expect(model.index(of: "non_existing") == nil)
    }

    @Test("Test delete function")
    func avatarGridModelDelete() async throws {
        #expect(model.index(of: "3") == 3)
        _ = model.deleteModel("3")
        #expect(model.index(of: "3") == nil)
    }

    @Test("Test set state function")
    func avatarGridModelSetState() async throws {
        #expect(model.model(with: "3")?.state == .loaded)
        model.setState(to: .loading, onAvatarWithID: "3")
        #expect(model.model(with: "3")?.state == .loading)
    }

    @Test("Test set state of non-existent avatar does nothing")
    func avatarGridModelSetStateNonExistent() async throws {
        #expect(!model.avatars.compactMap(\.state).contains(.loading))
        model.setState(to: .loading, onAvatarWithID: "non_existent")
        #expect(!model.avatars.compactMap(\.state).contains(.loading), "Should not ")
    }

    @Test("Test remove function")
    func avatarGridModelRemove() async throws {
        #expect(model.model(with: "3") != nil)
        model.removeModel("3")
        #expect(model.model(with: "3") == nil)
    }

    @Test("Test isEmpty function")
    func avatarGridModelisEmpty() async throws {
        #expect(model.isEmpty == false)
        model.setAvatars([])
        #expect(model.isEmpty)
    }

    @Test("Test insert function")
    func avatarGridModelInsert() async throws {
        let toInsert = AvatarImageModel.preview_init(id: "new", source: .remote(url: "https://example.com"))
        model.insert(toInsert, at: 2)

        #expect(model.index(of: "new") == 2)
    }

    @Test("Test replace function")
    func avatarGridModelReplace() async throws {
        let toReplace = AvatarImageModel.preview_init(id: "new", source: .remote(url: "https://example.com"))
        model.replaceModel(withID: "0", with: toReplace)

        #expect(model.index(of: "new") == 0)
    }

    @Test("Test replace with an existing ID")
    func avatarGridModelReplaceWithExistingID() async throws {
        // An element with ID "4" already exists in the model
        let toReplace = AvatarImageModel.preview_init(id: "4", source: .remote(url: "https://example.com"))
        // Replace an existing element with a new element whose ID is "4".
        model.replaceModel(withID: "0", with: toReplace)
        // Check how many items are present with ID == "4"
        let avatarCount = model.avatars.filter { $0.id == "4" }.count
        #expect(avatarCount == 1)
        #expect(model.index(of: "4") == 0)
    }
}
