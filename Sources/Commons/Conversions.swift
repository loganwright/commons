import Foundation

extension String {
    public var data: Data { Data(utf8) }
}

extension Data {
    public var string: String? { String(data: self, encoding: .utf8) }
}
