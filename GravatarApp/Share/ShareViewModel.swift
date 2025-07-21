import Combine
import Gravatar
import SwiftUI

@MainActor
class ShareViewModel: ObservableObject {
    @Published var contactPreviewURL: URL?
    @Published var profile: Profile
    @Published var qrCodeImage: Image?

    private let userSession: UserSession
    private var cancellables = Set<AnyCancellable>()
    let qrGenerator: QRGenerator
    var vcardGenerator: VCardGenerator

    @AppStorage("storedUserEmail")
    var storedUserEmail: String = ""

    @AppStorage("storedPhoneNumber")
    var storedPhoneNumber: String = ""

    @Published var share: ShareFieldsSelectionStore = .init()

    init(userSession: UserSession) {
        self.userSession = userSession
        self.profile = userSession.profile
        self.qrGenerator = QRGenerator()
        self.vcardGenerator = VCardGenerator(profile: userSession.profile)

        setupObservers()

        Task { @MainActor in
            await generateVCardQR()
        }
    }

    func setupObservers() {
        userSession.$profile
            .receive(on: RunLoop.main)
            .sink { [weak self] newProfile in
                self?.profile = newProfile
                self?.vcardGenerator = VCardGenerator(profile: newProfile)
            }
            .store(in: &cancellables)

        $share.sink { [weak self] _ in
            Task {
                await self?.generateVCardQR()
            }
        }.store(in: &cancellables)
    }

    func generateVCardQR() async {
        let vcardString = vcardGenerator.generate(with: vcardModel)
        let qrImage = await qrGenerator.generateQRCode(from: vcardString)
        withAnimation {
            qrCodeImage = qrImage
        }
    }

    func previewVCard() {
        let data = vcardGenerator.generate(with: vcardModel).data(using: .utf8)!
        let tempDirectory = FileManager.default.temporaryDirectory
        let url = tempDirectory.appendingPathComponent("contact.vcf")
        try! data.write(to: url)
        contactPreviewURL = url
    }

    var vcardModel: VCardModel {
        VCardModel(
            firstName: share.name ? profile.firstName ?? "" : "",
            lastName: share.name ? profile.lastName ?? "" : "",
            fullName: share.name ? profile.fullName ?? "" : "",
            displayName: profile.displayName,
            organization: share.company ? profile.company : "",
            jobTitle: share.jobTitle ? profile.jobTitle : "",
            phoneNumber: share.phone ? storedPhoneNumber : "",
            email: share.email ? storedUserEmail : "",
            profileURL: share.profileURL ? profile.profileUrl : ""
        )
    }
}
