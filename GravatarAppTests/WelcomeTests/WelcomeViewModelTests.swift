@testable import Analytics
import Foundation
import Gravatar
@testable import GravatarApp
import OAuth
import SwiftData
import Testing

@MainActor
final class WelcomeViewModelTests {
    let container = ModelContext.testContainer
    let profileService = TestProfileService()
    let oauthSession = TestOAuthSession(callbackURL: URL(string: "https://some.com")!)
    let tracker = TrackerMock()

    lazy var oauthManager = OAuthManager(
        authenticationSession: oauthSession,
        storage: TestSecureStorage(),
        callbackParser: TestCallbackParser(token: "token")
    )

    lazy var model = WelcomeViewModel(
        oauthManager: oauthManager,
        userDefaults: .testUserDefaults,
        analytics: Analytics(tracker: tracker, userUUIDStorage: UserUUIDStorageMock()),
        profileService: profileService,
        context: container.mainContext
    )

    init() async throws {
        Analytics.setPushEventsToRemote(true)
        UserDefaults.deleteTestData()
    }

    @Test("Login request made from Welcome view model succeeds")
    func loginSuccess() async throws {
        await model.requestOAuthToken()

        #expect(model.userSession != nil)
        #expect(model.userSession?.profile.fullName == "John Appleseed")
        #expect(model.userSession?.accessToken == "token")

        #expect(tracker.tracked(event: WelcomeScreenEvent.oauthStart))
        #expect(tracker.tracked(event: WelcomeScreenEvent.oauthSuccess))
        #expect(tracker.tracked(event: WelcomeScreenEvent.profileFetchStart))
        #expect(tracker.tracked(event: WelcomeScreenEvent.profileFetchSuccess))
        #expect(tracker.userName != nil)
    }

    @Test("Logout should reset user session")
    func logoutSuccess() async throws {
        await model.requestOAuthToken()

        #expect(model.userSession != nil)
        #expect(model.userSession?.profile.fullName == "John Appleseed")
        #expect(model.userSession?.accessToken == "token")
        #expect(tracker.userName != nil)

        await model.logout()

        #expect(model.userSession == nil)
        #expect(tracker.userName == nil)
    }

    @Test("Soft login should succeed")
    func softLoginSuccess() async throws {
        await model.requestOAuthToken()

        #expect(model.userSession != nil)
        #expect(model.userSession?.profile.fullName == "John Appleseed")
        #expect(model.userSession?.accessToken == "token")

        model.userSession = nil
        #expect(model.userSession == nil)

        model.softLogin()

        #expect(model.userSession != nil)
        #expect(model.userSession?.profile.fullName == "John Appleseed")
        #expect(model.userSession?.accessToken == "token")

        // Don't track oauth success on soft login. Expected 1 event from requestOAuthToken()
        #expect(tracker.tracked(event: WelcomeScreenEvent.oauthSuccess, count: 1))
        #expect(tracker.tracked(event: WelcomeScreenEvent.profileFetchSuccess, count: 1))
    }

    @Test("Oauth error should not create user session")
    func oauthError() async throws {
        oauthSession.error = .accessDenied

        await model.requestOAuthToken()

        #expect(model.userSession == nil)
        #expect(model.oauthError != nil)
        #expect(model.profileFetchingError == nil)

        #expect(tracker.tracked(event: WelcomeScreenEvent.oauthCancelled))
        #expect(tracker.tracked(event: WelcomeScreenEvent.oauthSuccess, count: 0))
    }

    @Test("Oauth error clears after successful login")
    func oauthErrorClears() async throws {
        oauthSession.error = .accessDenied

        await model.requestOAuthToken()

        #expect(model.userSession == nil)
        #expect(model.oauthError != nil)

        oauthSession.error = nil
        await model.requestOAuthToken()

        #expect(model.userSession != nil)
        #expect(model.oauthError == nil)
    }

    @Test("Profile error should not create user session")
    func profileError() async throws {
        profileService.error = .responseError(
            reason: .invalidHTTPStatusCode(response: .errorResponse(code: 401), errorPayload: nil)
        )

        await model.requestOAuthToken()

        #expect(model.userSession == nil)
        #expect(model.profileFetchingError != nil)
        #expect(model.oauthError == nil)

        #expect(tracker.tracked(event: WelcomeScreenEvent.profileFetchError(error: "")))
        #expect(tracker.tracked(event: WelcomeScreenEvent.profileFetchSuccess, count: 0))
    }

    @Test("Profile error clears after successful profile request")
    func profileErrorClears() async throws {
        profileService.error = .responseError(
            reason: .invalidHTTPStatusCode(response: .errorResponse(code: 401), errorPayload: nil)
        )

        await model.requestOAuthToken()

        #expect(model.userSession == nil)
        #expect(model.profileFetchingError != nil)
        #expect(model.localAccessToken == "token")

        profileService.error = nil
        await model.fetchProfile(with: model.localAccessToken!)

        #expect(model.userSession != nil)
        #expect(model.profileFetchingError == nil)
    }
}
