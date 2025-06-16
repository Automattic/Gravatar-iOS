import Foundation

public typealias EventProperties = (any Encodable & Sendable)

public protocol AnalyticsEvent: Sendable {
    var name: String { get }
    var properties: EventProperties? { get }
}

extension AnalyticsEvent {
    var jsonProperties: [String: AnyHashable]? {
        guard
            let properties,
            let data = try? JSONEncoder.snakeCaseEncoder.encode(properties)
        else { return nil }

        return (try? JSONSerialization.jsonObject(with: data)).flatMap { $0 as? [String: AnyHashable] }
    }
}

private extension JSONEncoder {
    static var snakeCaseEncoder: JSONEncoder {
        let decoder = JSONEncoder()
        decoder.keyEncodingStrategy = .convertToSnakeCase
        return decoder
    }
}
