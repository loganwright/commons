import Foundation

public protocol Model: Codable {
    static var encodingStrategy: JSONEncoder.KeyEncodingStrategy { get }
}
public extension Model {
    static var encodingStrategy: JSONEncoder.KeyEncodingStrategy { .useDefaultKeys }
}


extension Decodable {
    public static func decode(_ data: Data) throws -> Self {
        let decoder = JSONDecoder()
        // todo: move this to Model
        decoder.keyDecodingStrategy = .convertFromSnakeCase
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
        return try encoder.encode(self)
    }
}

extension Encodable where Self: Model {
    public func encoded(pretty: Bool = false) throws -> Data {
        let encoder = JSONEncoder()
        if pretty {
            encoder.outputFormatting = .prettyPrinted
        }
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try encoder.encode(self)
    }
}
