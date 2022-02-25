public struct HeaderKey: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public let stringValue: String

    public init(stringLiteral s: String) {
        self.stringValue = s
    }
    
    public init(_  s: String) {
        self.stringValue = s
    }
}

extension HeaderKey {
    public var contentType: HeaderKey { "Content-Type" }
    public var authorization: HeaderKey { "Authorization" }
    public var accept: HeaderKey { "Accept" }
}
