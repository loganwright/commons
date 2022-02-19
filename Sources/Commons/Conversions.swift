import Foundation

extension String {
    public var data: Data { Data(utf8) }
}

extension Data {
    public var string: String? { String(data: self, encoding: .utf8) }
}

extension Data {
    public init<T>(byteRepresentationOf value: T) {
        var value = value
        self = Data(bytes: &value, count: MemoryLayout<T>.size)
    }
}
