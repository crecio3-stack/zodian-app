import Foundation
import Network

@MainActor
final class NetworkHealthMonitor {
    static let shared = NetworkHealthMonitor()

    enum Status: String {
        case satisfied
        case unsatisfied
        case requiresConnection = "requires_connection"
        case unknown
    }

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.zodian.network-health")
    private var hasStarted = false

    private init() {}

    func start() {
        guard !hasStarted else { return }
        hasStarted = true

        monitor.pathUpdateHandler = { path in
            let nextStatus: Status
            switch path.status {
            case .satisfied:
                nextStatus = .satisfied
            case .unsatisfied:
                nextStatus = .unsatisfied
            case .requiresConnection:
                nextStatus = .requiresConnection
            @unknown default:
                nextStatus = .unknown
            }

            let expensive = path.isExpensive
            let constrained = path.isConstrained

            Task { @MainActor in
                OperationalLogger.info(
                    "network_health_changed",
                    category: .network,
                    metadata: [
                        "status": nextStatus.rawValue,
                        "expensive": String(expensive),
                        "constrained": String(constrained)
                    ]
                )
            }
        }

        monitor.start(queue: queue)
    }
}
