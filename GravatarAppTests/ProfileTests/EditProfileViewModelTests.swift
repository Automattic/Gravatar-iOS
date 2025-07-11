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
        #expect(model.hasDifference(in: field) == false, "No changes")
        #expect(model.hasUnsavedChanges == false)
        model.fields.setValue("\(initialValue)_edit", for: field)
        #expect(model.hasDifference(in: field) == true, "There has to be unsaved changes")
        #expect(model.hasUnsavedChanges == true)
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
    private func newModel(
        userSession: UserSession? = nil,
        session: URLSessionProtocol = URLSessionMock()
    ) -> EditProfileViewModel {
        let model = EditProfileViewModel(
            userSession: userSession ?? UserSession(profile: .full, accessToken: "token", context: .testContext),
            urlSession: session,
            networkMonitor: TestNetworkMonitor()
        )
        return model
    }
}

extension ProfileFieldsModel {
    func value(for field: ProfileField) -> String {
        switch field {
        case .displayName:
            displayName
        case .aboutMe:
            aboutMe
        case .pronunciation:
            pronunciation
        case .pronouns:
            pronouns
        case .location:
            location
        case .firstName:
            firstName
        case .lastName:
            lastName
        case .company:
            company
        case .jobTitle:
            jobTitle
        }
    }

    func setValue(_ value: String, for field: ProfileField) {
        switch field {
        case .displayName:
            displayName = value
        case .aboutMe:
            aboutMe = value
        case .pronunciation:
            pronunciation = value
        case .pronouns:
            pronouns = value
        case .location:
            location = value
        case .firstName:
            firstName = value
        case .lastName:
            lastName = value
        case .company:
            company = value
        case .jobTitle:
            jobTitle = value
        }
    }
}
