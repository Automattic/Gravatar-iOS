import Foundation
@testable import GravatarApp
import SnapshotTesting
import SwiftUICore
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct ToastViewTests {
    @MainActor
    @Test(
        "Toast View displays correctly",
        arguments: [(ToastType.error, "This is an error toast!"), (ToastType.info, "This is an info toast!")]
    )
    func toast(at input: (ToastType, String)) async throws {
        let view =
            VStack(spacing: 0) {
                Toast(toast: .init(
                    message: input.1,
                    type: input.0,
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
            ],
            testName: "toast-\(input.0)"
        )
    }
}
