import Combine
import Foundation
@testable import GravatarApp
import GravatarUI
import SwiftUI
import Testing

final class EditProfileViewModelTests {
    var cancellables = Set<AnyCancellable>()

    @MainActor
    @Test("Unsaved changes are detected correctly", arguments: ProfileField.allCases)
    func hasUnsavedChanges(field: ProfileField) async throws {
        let model = newModel()
        let initialValue = model.fields.value(for: field)
        #expect(model.hasUnsavedChanges(field, value: .constant(initialValue ?? "")) == false, "No changes")
        #expect(model.hasUnsavedChanges(field, value: .constant("\(initialValue ?? "")_edit")) == true, "There has to be unsaved changes")
    }

    @MainActor
    @Test("isSaving flag is toggled correctly either when service call is successful or not", arguments: [true, false])
    func isSavingFlag(isSuccess: Bool) async throws {
        let model = newModel(session: isSuccess ? URLSessionMock() : URLSessionMock(returnErrorCode: 400))
        var count = 0
        await confirmation(expectedCount: 2) { confirmation in
            model.$isSaving.dropFirst(1).sink { isSaving in
                if count == 0 {
                    #expect(isSaving == true)
                    confirmation.confirm()
                } else if count == 1 {
                    #expect(isSaving == false)
                    confirmation.confirm()
                }
                count += 1
            }
            .store(in: &cancellables)

            await model.save()
        }
    }

    @MainActor
    @Test("The whitespaces are trimmed before saving")
    func whitespaceTrimBeforeSave() async throws {
        let mockSession = ProfileSaveSessionMock()
        let model = newModel(session: mockSession)
        for field in ProfileField.allCases {
            let initialValue = model.fields.value(for: field)
            let newValue = " \n\t" + (initialValue ?? "") + " \n\t" // add some whitespaces
            model.fields.setValue(newValue, for: field)
        }
        await model.save()

        // get the request body
        guard let body = mockSession.savedRequest?.httpBody,
              let jsonObject = try? JSONSerialization.jsonObject(with: body, options: []) as? [String: Any]
        else {
            #expect(Bool(false), "request is empty")
            return
        }

        // check if values are trimmed
        for key in jsonObject.keys {
            if let value = jsonObject[key] as? String {
                #expect(value == value.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }

    @MainActor
    private func newModel(session: URLSessionProtocol = URLSessionMock()) -> EditProfileViewModel {
        let model = EditProfileViewModel(
            userSession: UserSession(profile: .full, accessToken: "token", context: .testContext),
            urlSession: session,
            networkMonitor: TestNetworkMonitor()
        )
        return model
    }
}

private class ProfileSaveSessionMock: URLSessionProtocol, @unchecked Sendable {
    var savedRequest: URLRequest?
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        savedRequest = request
        return (Bundle.fullProfileJsonData, HTTPURLResponse.successResponse())
    }

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        (Bundle.postAvatarUploadJsonData, HTTPURLResponse.successResponse())
    }
}
