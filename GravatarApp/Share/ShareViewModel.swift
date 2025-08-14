import Analytics
import Combine
import Gravatar
import SwiftUI

@MainActor
class ShareViewModel: ObservableObject {
    private enum StorageKeys {
        static let email = "storedUserEmail"
        static let phone = "storedPhoneNumber"
    }

    @Published var contactPreviewURL: URL?
    @Published var profile: Profile
    @Published var qrCodeImage: Image?
    @Published var shareVCardURL: URL?
    @Published var share: ShareFieldsSelectionStore

    private let userSession: UserSession
    private var cancellables = Set<AnyCancellable>()
    private let urlSession: any URLSessionProtocol
    private let networkMonitor: NetworkMonitor
    private let userDefaults: UserDefaults

    private let qrGenerator: QRGenerator

    @Published var storedUserEmail: String {
        didSet { userDefaults.set(storedUserEmail, forKey: StorageKeys.email) }
    }

    @Published var storedPhoneNumber: String {
        didSet { userDefaults.set(storedPhoneNumber, forKey: StorageKeys.phone) }
    }

    init(
        userSession: UserSession,
        urlSession: URLSessionProtocol? = nil,
        networkMonitor: NetworkMonitor = SystemNetworkMonitor.shared,
        userDefaults: UserDefaults = .standard,
        analytics: Analytics = .shared
    ) {
        self.userSession = userSession
        self.profile = userSession.profile
        self.qrGenerator = QRGenerator()
        self.urlSession = urlSession ?? GravatarURLSession.shared
        self.networkMonitor = networkMonitor
        self.share = .init(userDefaults: userDefaults, analytics: analytics)
        self.userDefaults = userDefaults

        storedUserEmail = userDefaults.string(forKey: StorageKeys.email) ?? ""
        storedPhoneNumber = userDefaults.string(forKey: StorageKeys.phone) ?? ""

        setupObservers()

        Task { @MainActor in
            await generateVCardQR()
            // Pre-fetch the user avatar for fast response on share/preview actions.
            refreshUserAvatar()
        }
    }

    private func setupObservers() {
        userSession.$profile
            .receive(on: RunLoop.main)
            .sink { [weak self] newProfile in
                self?.profile = newProfile
            }
            .store(in: &cancellables)

        share.objectWillChange.sink { [weak self] _ in
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
        let vcardString = vcardModel().generateVCard()
        let qrImage = await qrGenerator.generateQRCode(from: vcardString)
        withAnimation {
            qrCodeImage = qrImage
        }
    }

    func previewVCard() {
        Task {
            let data = await getVCard(withAvatarData: false)
            let url = getURL(for: data)
            Task { @MainActor in
                contactPreviewURL = url
            }
        }
    }

    func shareVCard() async {
        let vCardString = await getVCard(withAvatarData: true)
        shareVCardURL = getURL(for: vCardString)
    }

    private func getURL(for vCardString: String) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let url = tempDirectory.appendingPathComponent("\(profile.displayName).vcf")
        try? vCardString.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private func getVCard(withAvatarData: Bool = true) async -> String {
        let data = withAvatarData ? await fetchAvatarData() : nil
        let vCardModel = vcardModel(with: data)
        return vCardModel.generateVCard()
    }

    private func fetchAvatarData() async -> Data? {
        let service = AvatarService(urlSession: urlSession)
        do {
            let result = try await service.fetch(
                with: .hashID(profile.hash),
                options: .init(preferredSize: .preferredSize)
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
            location: share.location ? profile.location : "",
            phoneNumber: share.phone ? storedPhoneNumber : "",
            email: share.email ? storedUserEmail : "",
            profileURL: share.profileURL ? profile.profileUrl : "",
            description: share.description ? profile.description : "",
            avatarData: avatarData,
            accounts: profile.verifiedAccounts.filter { share.account($0) }.map()
        )
    }
}
