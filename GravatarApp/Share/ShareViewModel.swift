import Combine
import Gravatar
import SwiftUI

@MainActor
class ShareViewModel: ObservableObject {
    @Published var contactPreviewURL: URL?
    @Published var profile: Profile
    @Published var qrCodeImage: Image?
    @Published var shareVCardURL: URL?
    @Published var share: ShareFieldsSelectionStore = .init()

    private let userSession: UserSession
    private var cancellables = Set<AnyCancellable>()
    //   private var avatarData: Data?
    //   private var avatarDownloadTask: Task<Data?, Never>?
    private let notificationCenter: NotificationCenter
    private let urlSession: any URLSessionProtocol
    private let networkMonitor: NetworkMonitor

    let qrGenerator: QRGenerator
    private(set) var vcardGenerator: VCardGenerator

    @AppStorage("storedUserEmail")
    var storedUserEmail: String = ""

    @AppStorage("storedPhoneNumber")
    var storedPhoneNumber: String = ""

    init(
        userSession: UserSession,
        notificationCenter: NotificationCenter = .default,
        urlSession: URLSessionProtocol? = nil,
        networkMonitor: NetworkMonitor = SystemNetworkMonitor.shared
    ) {
        self.userSession = userSession
        self.profile = userSession.profile
        self.qrGenerator = QRGenerator()
        self.vcardGenerator = VCardGenerator(profile: userSession.profile)
        self.notificationCenter = notificationCenter
        self.urlSession = urlSession ?? GravatarURLSession.shared
        self.networkMonitor = networkMonitor

        setupObservers()

        Task { @MainActor in
            await generateVCardQR()
            // Pre-fetch the user avatar for fast response on share/preview actions.
            refreshUserAvatar()
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

        networkMonitor.hasNetworkConnection.dropFirst().sink { [weak self] newValue in
            if newValue {
                self?.refreshUserAvatar()
            }
        }.store(in: &cancellables)
    }

    func generateVCardQR() async {
        let vcardString = vcardGenerator.generate(with: vcardModel())
        let qrImage = await qrGenerator.generateQRCode(from: vcardString)
        withAnimation {
            qrCodeImage = qrImage
        }
    }

    func previewVCard() {
        Task {
            let data = await getVCardWithAvatarData()
            let url = getURL(for: data)
            Task { @MainActor in
                contactPreviewURL = url
            }
        }
    }

    func shareVCard() async {
        let vCardString = await getVCardWithAvatarData()
        shareVCardURL = getURL(for: vCardString)
    }

    private func getURL(for vCardString: String) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let url = tempDirectory.appendingPathComponent("\(profile.displayName).vcf")
        try? vCardString.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private func getVCardWithAvatarData() async -> String {
        let data = await fetchAvatarData()
        let vCardModel = vcardModel(with: data)
        return vcardGenerator.generate(with: vCardModel)
    }

    private func fetchAvatarData() async -> Data? {
        let service = AvatarService(urlSession: urlSession)
        do {
            let result = try await service.fetch(
                with: .hashID(profile.hash),
                options: .init(preferredSize: .pixels(256))
            )
            return result.image.jpegData(compressionQuality: 0.7)
        } catch {
            return nil
        }
    }

    func refreshUserAvatar() {
        Task {
            await fetchAvatarData()
        }
    }

    func vcardModel(with avatarData: Data? = nil) -> VCardModel {
        VCardModel(
            firstName: share.name ? profile.firstName ?? "" : "",
            lastName: share.name ? profile.lastName ?? "" : "",
            fullName: share.name ? profile.fullName ?? "" : "",
            displayName: profile.displayName,
            organization: share.company ? profile.company : "",
            jobTitle: share.jobTitle ? profile.jobTitle : "",
            phoneNumber: share.phone ? storedPhoneNumber : "",
            email: share.email ? storedUserEmail : "",
            profileURL: share.profileURL ? profile.profileUrl : "",
            description: share.description ? profile.description : "",
            avatarData: avatarData
        )
    }
}
