import Foundation
@testable import GravatarApp
import SnapshotTesting
import SwiftUICore
import Testing

@Suite(.snapshots(record: .all, diffTool: .ksdiff))
struct StatefulTextFieldTests {

    @MainActor
    @Test(arguments: [
        Config(isLarge: false, isDisabled: false, hasUnsavedChanges: false, isFocused: false),
        Config(isLarge: false, isDisabled: true, hasUnsavedChanges: false, isFocused: false),
        Config(isLarge: false, isDisabled: false, hasUnsavedChanges: true, isFocused: false),
        Config(isLarge: false, isDisabled: false, hasUnsavedChanges: true, isFocused: true),
        Config(isLarge: true, isDisabled: false, hasUnsavedChanges: false, isFocused: false),
        Config(isLarge: true, isDisabled: true, hasUnsavedChanges: false, isFocused: false),
        Config(isLarge: true, isDisabled: false, hasUnsavedChanges: true, isFocused: false),
        Config(isLarge: true, isDisabled: false, hasUnsavedChanges: true, isFocused: true),
    ])
    func differentStates(config: Config) async throws {
        let view = StatefulTextField(
            isLarge: config.isLarge,
            accessibilityLabel: "label",
            fieldIdentifier: "identifier",
            value: .constant("input text"),
            isDisabled: { config.isDisabled },
            hasUnsavedChanges: { config.hasUnsavedChanges },
            forceFocusedState: config.isFocused
        )
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0)
        .padding()
        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ],
            testName: "StatefulTextField-\(config.identifier)"
        )
    }

    struct Config {
        let isLarge: Bool
        let isDisabled: Bool
        let hasUnsavedChanges: Bool
        let isFocused: Bool

        var identifier: String {
            "\(isLarge ? "large" : "small")-\(isFocused ? "focused" : "unfocused")-\(hasUnsavedChanges ? "dirty" : "clean")-\(isDisabled ? "disabled" : "enabled"),"
        }
    }
}
