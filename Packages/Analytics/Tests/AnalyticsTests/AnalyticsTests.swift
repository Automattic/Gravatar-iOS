@testable import Analytics
import Testing

@MainActor
@Test("Test analytics init configuration is called")
func configurationCalled() async throws {
    let tracker = TrackerMock()
    _ = Analytics(tracker: tracker)
    #expect(tracker.configureCalled == true)
}

@MainActor
@Test("Test user is logged out on init")
func userLoggedOut() async throws {
    let tracker = TrackerMock()
    _ = Analytics(tracker: tracker)
    #expect(tracker.userProperties["user_is_logged_in"] as? Bool == false)
}

@MainActor
@Test("Test user is logged in")
func userLoggedIn() async throws {
    let tracker = TrackerMock()
    let analytics = Analytics(tracker: tracker)
    analytics.setUserId("user")

    #expect(tracker.userProperties["user_is_logged_in"] as? Bool == true)
}

@MainActor
@Test("Test event is tracked")
func eventIsTracked() async throws {
    let tracker = TrackerMock()
    let analytics = Analytics(tracker: tracker)
    analytics.track(TestEvent())

    #expect(tracker.eventTracked == TestEvent().name)
}

@MainActor
@Test("Test event property is tracked with snake_case")
func eventIsTrackedProperties() async throws {
    let tracker = TrackerMock()
    let analytics = Analytics(tracker: tracker)
    analytics.track(TestEventWithProperties())

    #expect(tracker.eventTracked == TestEventWithProperties().name)
    #expect(tracker.propertiesTracked?["test_property_key"] as? String == "property_value")
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
