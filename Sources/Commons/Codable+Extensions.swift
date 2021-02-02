import Foundation

public protocol CustomEncodingStrategy {
    static var encodingStrategy: JSONEncoder.KeyEncodingStrategy { get }
}

extension CustomEncodingStrategy {
    fileprivate var encodingStrategy: JSONEncoder.KeyEncodingStrategy {
        Self.encodingStrategy
    }
}

extension Decodable {
    public static func decode(_ data: Data, strategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase) throws -> Self {
        let decoder = JSONDecoder()
        // todo: move this to Model
        decoder.keyDecodingStrategy = strategy
        return try decoder.decode(Self.self, from: data)
    }

    public init(jsonData: Data) throws {
        self = try Self.decode(jsonData)
    }
}

extension Encodable {
    public func encoded(pretty: Bool = false) throws -> Data {
        let encoder = JSONEncoder()
        if pretty {
            encoder.outputFormatting = .prettyPrinted
        }
        if let strat = self as? CustomEncodingStrategy {
            encoder.keyEncodingStrategy = strat.encodingStrategy
        }
        return try encoder.encode(self)
    }
}
