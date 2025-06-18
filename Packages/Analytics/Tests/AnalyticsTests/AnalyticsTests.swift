@testable import Analytics
import Foundation
import Testing

struct AnalyticsTests {
    let userUUIDStorage = UserUUIDStorageMock()

    @Test("Test analytics init configuration is called")
    func configurationCalled() async throws {
        let tracker = TrackerMock()
        _ = Analytics(tracker: tracker, userUUIDStorage: userUUIDStorage)
        #expect(tracker.configureCalled == true)
    }

    @Test("Test user is logged out on init")
    func userInitialLoggedOut() async throws {
        let tracker = TrackerMock()
        _ = Analytics(tracker: tracker, userUUIDStorage: userUUIDStorage)
        #expect(tracker.userProperties["user_is_logged_in"] as? Bool == false)
    }

    @Test("Test user is logged in")
    func userLoggedIn() async throws {
        let tracker = TrackerMock()
        let analytics = Analytics(tracker: tracker, userUUIDStorage: userUUIDStorage)
        analytics.setUserID("user")

        #expect(tracker.userProperties["user_is_logged_in"] as? Bool == true)
        #expect(tracker.userID == "user")
    }

    @Test("Test user is logged out after being logged in")
    func userSetToLoggedOut() async throws {
        let tracker = TrackerMock()
        let analytics = Analytics(tracker: tracker, userUUIDStorage: userUUIDStorage)
        analytics.setUserID("user")

        #expect(tracker.userProperties["user_is_logged_in"] as? Bool == true)
        #expect(tracker.userID == "user")

        analytics.setUserID(nil)

        #expect(tracker.userProperties["user_is_logged_in"] as? Bool == false)
        #expect(tracker.userID == nil)
    }

    @Test("Test user UUD is created and persisted")
    func userUUID() async throws {
        let tracker = TrackerMock()
        let analytics = Analytics(tracker: tracker, userUUIDStorage: userUUIDStorage)
        analytics.setUserID("user")

        #expect(tracker.userProperties["user_is_logged_in"] as? Bool == true)
    }

    @Test("Test event is tracked")
    func eventIsTracked() async throws {
        let tracker = TrackerMock()
        let analytics = Analytics(tracker: tracker, userUUIDStorage: userUUIDStorage)
        analytics.track(TestEvent())

        #expect(tracker.eventTracked == TestEvent().name)
    }

    @Test("Test event property is tracked with snake_case")
    func eventIsTrackedProperties() async throws {
        let tracker = TrackerMock()
        let analytics = Analytics(tracker: tracker, userUUIDStorage: userUUIDStorage)
        analytics.track(TestEventWithProperties())

        #expect(tracker.eventTracked == TestEventWithProperties().name)
        #expect(tracker.propertiesTracked?["test_property_key"] as? String == "property_value")
    }

    @Test("User UUID is created for anonymous users")
    func userUUIDForAnonymousUsers() async throws {
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
