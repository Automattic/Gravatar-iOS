@testable import Analytics
@testable import GravatarApp
import Testing

struct AvatarPickerViewEventsTests {
    @Test
    func screenView() async throws {
        let event = AvatarPickerViewEvents.screenView
        #expect(event.name == "screen_view")
        #expect(event.jsonProperties?["screen"] as? String == "avatars")
    }

    @Test
    func screenLeave() async throws {
        let event = AvatarPickerViewEvents.screenLeave
        #expect(event.name == "screen_leave")
        #expect(event.jsonProperties?["screen"] as? String == "avatars")
    }

    @Test
    func mainMenuTapped() async throws {
        let event = AvatarPickerViewEvents.mainMenuTapped
        #expect(event.name == "mainmenu_tapped")
        #expect(event.jsonProperties?["screen"] as? String == "avatars")
    }

    @Test
    func avatarsGridItemTapped() async throws {
        let event = AvatarPickerViewEvents.avatarsGridItemTapped
        #expect(event.name == "avatars_grid_item_tapped")
    }

    @Test
    func avatarsCameraButtonTapped() async throws {
        let event = AvatarPickerViewEvents.avatarsCameraButtonTapped
        #expect(event.name == "avatars_camera_button_tapped")
    }

    @Test
    func avatarsPhotosButtonTapped() async throws {
        let event = AvatarPickerViewEvents.avatarsPhotosButtonTapped
        #expect(event.name == "avatars_photos_button_tapped")
    }

    @Test
    func avatarsAIButtonTapped() async throws {
        let event = AvatarPickerViewEvents.avatarsAIButtonTapped
        #expect(event.name == "avatars_ai_button_tapped")
    }
}
