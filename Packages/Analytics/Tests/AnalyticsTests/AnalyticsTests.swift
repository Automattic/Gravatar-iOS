@testable import Analytics
import Foundation
import Testing

struct AnalyticsTests {
    let userUUIDStorage = UserUUIDStorageMock()
    let tracker = TrackerMock()
    let analytics: Analytics

    init() {
        self.analytics = Analytics(tracker: tracker, userUUIDStorage: userUUIDStorage)
    }

    @Test("Test analytics init configuration is called")
    func configurationCalled() async throws {
        #expect(tracker.configureCalled == true)
    }

    @Test("Test user is logged in")
    func userLoggedIn() async throws {
        await analytics.setUserName("user")

        #expect(tracker.userProperties["user_is_logged_in"] as? Bool == true)
        #expect(tracker.userName == "user")
    }

    @Test("Test user is logged out after being logged in")
    func userSetToLoggedOut() async throws {
        await analytics.setUserName("user")

        #expect(tracker.userProperties["user_is_logged_in"] as? Bool == true)
        #expect(tracker.userName == "user")

        await analytics.setUserName(nil)

        #expect(tracker.userProperties["user_is_logged_in"] as? Bool == false)
        #expect(tracker.userName == nil)
    }

    @Test("Test user UUD is created and persisted")
    func userUUID() async throws {
        await analytics.setUserName("user")

        #expect(tracker.userProperties["user_is_logged_in"] as? Bool == true)
    }

    @Test("Test event is tracked")
    func eventIsTracked() async throws {
        analytics.track(TestEvent())

        #expect(tracker.eventTracked == TestEvent().name)
    }

    @Test("Test event property is tracked with snake_case")
    func eventIsTrackedProperties() async throws {
        analytics.track(TestEventWithProperties())

        #expect(tracker.eventTracked == TestEventWithProperties().name)
        #expect(tracker.propertiesTracked?["test_property_key"] as? String == "property_value")
    }

    @Test("User UUID is created for anonymous users")
    func userUUIDForAnonymousUsers() async throws {
        let userUUIDStorage = UserUUIDStorageMock()
        let tracker = TrackerMock()
        #expect(userUUIDStorage.uuid == nil)

        _ = Analytics(tracker: tracker, userUUIDStorage: userUUIDStorage)

        #expect(userUUIDStorage.uuid != nil)
    }
}

struct TestEvent: AnalyticsEvent {
    var name: String = "test_event"
    let properties: EventProperties? = nil
}

struct TestEventWithProperties: AnalyticsEvent {
    struct Properties: Encodable, Sendable {
        let testPropertyKey: String
    }

    var name: String = "test_event_with_properties"
    let properties: EventProperties? = Properties(testPropertyKey: "property_value")
}
