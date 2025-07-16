import Foundation
@testable import GravatarApp
import SnapshotTesting
import Testing
import UIKit

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
@MainActor
struct AvatarPickerAvatarViewTests {
    @Test("Avatar view cell in normal state")
    func avatarCellNormalState() async throws {
        let avatar = AvatarImageModel.preview_init(source: .local(image: ImageHelper.testProfileImage))

        let view = AvatarPickerAvatarView(avatar: avatar, maxSize: 90, minSize: 80) {
            false
        } avatarUploadErrorAction: { _ in
        } onActionSelected: { _ in }

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @Test("Avatar view cell in selected state")
    func avatarCellSelectedState() async throws {
        let avatar = AvatarImageModel.preview_init(source: .local(image: ImageHelper.testProfileImage))

        let view = AvatarPickerAvatarView(avatar: avatar, maxSize: 90, minSize: 80) {
            true
        } avatarUploadErrorAction: { _ in
        } onActionSelected: { _ in }
            .transaction { transaction in
                transaction.animation = nil
            }

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @Test("Avatar view cell in loading state")
    func avatarCellLoadingState() async throws {
        let avatarLoading = AvatarImageModel.preview_init(source: .local(image: ImageHelper.testProfileImage), state: .loading)

        let view = AvatarPickerAvatarView(avatar: avatarLoading, maxSize: 90, minSize: 80) {
            false
        } avatarUploadErrorAction: { _ in
        } onActionSelected: { _ in }
            .transaction { transaction in
                transaction.animation = nil
            }

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @Test("Avatar view cell in error state")
    func avatarCellErrorState() async throws {
        let avatarError = AvatarImageModel.preview_init(source: .local(image: ImageHelper.testProfileImage), state: .error(
            supportsRetry: true,
            errorMessage: "Something went wrong. Retry?"
        ))
        let view = AvatarPickerAvatarView(avatar: avatarError, maxSize: 90, minSize: 80) {
            false
        } avatarUploadErrorAction: { _ in
        } onActionSelected: { _ in }
            .transaction { transaction in
                transaction.animation = nil
            }

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }
}
