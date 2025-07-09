import Foundation
import Network
import Observation

@MainActor
protocol NetworkMonitor: Sendable {
    var hasNetworkConnection: Published<Bool>.Publisher { get }
}

@MainActor
final class SystemNetworkMonitor: NetworkMonitor {
    static let shared = SystemNetworkMonitor()

    @Published private var internalHasNetworkConnection: Bool = true

    var hasNetworkConnection: Published<Bool>.Publisher { $internalHasNetworkConnection }

    private let networkMonitor = NWPathMonitor()

    private init() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            Task {
                await self?.updateNetworkConnectionStatus(to: path.status == .satisfied)
            }
        }

        networkMonitor.start(queue: DispatchQueue.global())
    }

    private func updateNetworkConnectionStatus(to newStatus: Bool) async {
        guard internalHasNetworkConnection != newStatus else { return }
        internalHasNetworkConnection = newStatus
    }
}
