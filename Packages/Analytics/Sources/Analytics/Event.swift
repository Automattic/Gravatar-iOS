import Foundation

public typealias EventProperties = (Encodable & Sendable)

public protocol AnalyticsEvent: Sendable {
    var name: String { get }
    var properties: EventProperties? { get }
}

extension AnalyticsEvent {
    var dictionaryProperties: [String: AnyHashable]? {
        guard
            let data = jsonDataProperties
        else { return nil }

        return (try? JSONSerialization.jsonObject(with: data)).flatMap { $0 as? [String: AnyHashable] }
    }

    var jsonDataProperties: Data? {
        guard let properties else { return nil }
        return try? JSONEncoder.snakeCaseEncoder.encode(properties)
    }

    var jsonStringProperties: String? {
        guard let data = jsonDataProperties else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension JSONEncoder {
    fileprivate static var snakeCaseEncoder: JSONEncoder {
        let decoder = JSONEncoder()
        decoder.keyEncodingStrategy = .convertToSnakeCase
        return decoder
    }
}
