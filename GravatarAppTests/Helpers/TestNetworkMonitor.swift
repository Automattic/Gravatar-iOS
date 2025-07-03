import Combine
@testable import GravatarApp

class TestNetworkMonitor: NetworkMonitor {
    var hasNetworkConnection: Published<Bool>.Publisher { $isConnected }

    @Published var isConnected = true
}
