@testable import Analytics
import Foundation
import Testing

@Test("Test User UUID Storage")
func userUUIDStorage() async throws {
    let userUUIDStorage = UserUUIDStorageMock()

    #expect(userUUIDStorage.uuid == nil)

    let userID = UserUUID(storage: userUUIDStorage).uuidString

    #expect(userUUIDStorage.uuid == userID)
    // Will not create a new UUID for the user
    #expect(UserUUID(storage: userUUIDStorage).uuidString == userID)
}
