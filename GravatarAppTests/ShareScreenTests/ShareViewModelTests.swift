import Foundation
import Gravatar
@testable import GravatarApp
import SnapshotTesting
import Testing

@MainActor
@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct ShareViewModelTests {
    let networkMonitor = TestNetworkMonitor()
    let urlSession = URLSessionMock()

    @Test("Tets the vcard share link URL is generated with the correct data")
    func shareVCardWithFullData() async throws {
        let viewModel = createViewModel()

        await viewModel.shareVCard()

        #expect(viewModel.shareVCardURL != nil)

        let vCard = try String(contentsOf: viewModel.shareVCardURL!, encoding: .utf8)
        print("Stored data 1: \(String(describing: UserDefaults.testUserDefaults.value(forKey: "https://notreal.wordpress.com") as? Bool))")

        #expect(vCard.contains("N:Appleseed;John;"))
        #expect(vCard.contains("FN:\n")) // Always empty
        #expect(vCard.contains("NICKNAME:John Appleseed"))
        #expect(vCard.contains("ORG:A company"))
        #expect(vCard.contains("TITLE:Engineer"))
        #expect(vCard.contains("URL:https://gravatar.com/notreal"))
        #expect(vCard.contains("ADR;CHARSET=UTF-8;TYPE=HOME:;;;Atlanta GA;;;"))
        #expect(vCard.contains("URL;TYPE=\"WordPress\":https://notreal.wordpress.com"))
        #expect(vCard.contains("NOTE:I'm a "))
        #expect(vCard.contains("EMAIL:notreal@example.com"))
        #expect(vCard.contains("TEL:+1234567890"))
        #expect(vCard.contains("PHOTO;ENCODING=b;TYPE=JPEG:/9j/4"))

        UserDefaults.deleteTestData(named: #function)
    }

    @Test("Tets the vcard share link URL is generated with the correct data when no data is shared")
    func shareVCardWithNoData() async throws {
        let viewModel = createViewModel()
        viewModel.share.email = false
        viewModel.share.phone = false
        viewModel.share.name = false
        viewModel.share.location = false
        viewModel.share.jobTitle = false
        viewModel.share.company = false
        viewModel.share.description = false
        viewModel.share.profileURL = false
        viewModel.share.set(verifiedAccount, to: false)

        await viewModel.shareVCard()

        #expect(viewModel.shareVCardURL != nil)

        let vCard = try String(contentsOf: viewModel.shareVCardURL!, encoding: .utf8)

        // Expected
        #expect(vCard.contains("FN:\n")) // Always empty
        #expect(vCard.contains("NICKNAME:John Appleseed"))
        #expect(vCard.contains("PHOTO;ENCODING=b;TYPE=JPEG:/9j/4"))
        // Not expected
        #expect(!vCard.contains("N:Appleseed;John;"))
        #expect(!vCard.contains("ORG:A company"))
        #expect(!vCard.contains("TITLE:Engineer"))
        #expect(!vCard.contains("URL:https://gravatar.com/notreal"))
        #expect(!vCard.contains("ADR;CHARSET=UTF-8;TYPE=HOME:;;;Atlanta GA;;;"))
        #expect(!vCard.contains("URL;TYPE=\"WordPress\":https://notreal.wordpress.com"))
        #expect(!vCard.contains("NOTE:I'm a "))
        #expect(!vCard.contains("EMAIL:notreal@example.com"))
        #expect(!vCard.contains("TEL:+1234567890"))

        UserDefaults.deleteTestData(named: #function)
    }

    @Test("Test the qr code is generated correctly with all data")
    func qrCodeGeneratedFullData() async throws {
        let viewModel = createViewModel()

        await viewModel.generateVCardQR()

        #expect(viewModel.qrCodeImage != nil)
        let image = viewModel.qrCodeImage!.resizable().frame(width: 100, height: 100)

        assertSnapshots(of: image, as: [.image])
    }

    @Test("Test the qr code is generated correctly with minimal data")
    func qrCodeGeneratedMinimalData() async throws {
        let viewModel = createViewModel()

        viewModel.share.email = false
        viewModel.share.phone = false
        viewModel.share.name = false
        viewModel.share.location = false
        viewModel.share.jobTitle = false
        viewModel.share.company = false
        viewModel.share.description = false
        viewModel.share.profileURL = false
        viewModel.share.set(verifiedAccount, to: false)

        await viewModel.generateVCardQR()

        #expect(viewModel.qrCodeImage != nil)
        let image = viewModel.qrCodeImage!.resizable().frame(width: 100, height: 100)

        assertSnapshots(of: image, as: [.image])
    }
}

@MainActor
private func createViewModel(_ testUnitName: String = #function) -> ShareViewModel {
    let viewModel = ShareViewModel(
        userSession: UserSession(
            profile: .full,
            accessToken: "",
            context: .testContext,
            networkMonitor: TestNetworkMonitor(),
            urlSession: URLSessionMock()
        ),
        urlSession: URLSessionMock(),
        networkMonitor: TestNetworkMonitor(),
        // These tests run in parallel, so we need different UserDefaults for each one of them.
        userDefaults: .testUserDefaults(named: testUnitName)
    )
    viewModel.storedUserEmail = "notreal@example.com"
    viewModel.storedPhoneNumber = "+1234567890"
    return viewModel
}

private var verifiedAccount: VerifiedAccount {
    Profile.full.verifiedAccounts[0]
}
