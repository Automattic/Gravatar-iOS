import Foundation
@testable import GravatarApp
import SnapshotTesting
import SwiftUICore
import Testing

@Suite(.snapshots(record: .all, diffTool: .ksdiff))
struct ToastViewTests {
    @MainActor
    @Test
    func errorToast() async throws {
        let view =
            VStack(spacing: 0) {
                Toast(toast: .init(
                    message: "This is an error toast!",
                    type: .info,
                    stackingBehavior: .avoidStackingWithSameMessage
                )) { _ in
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0)
                .padding()
            }
            .background(Color.clear)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @MainActor
    @Test
    func infoToast() async throws {
        let view = VStack(spacing: 0) {
            Toast(toast: .init(
                message: "This is an info toast!",
                type: .info,
                stackingBehavior: .avoidStackingWithSameMessage
            )) { _ in
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0)
            .padding()
        }
        .background(Color.clear)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }
}
