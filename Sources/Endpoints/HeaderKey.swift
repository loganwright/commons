///
/// to define custom header keys extend this
///
///     extension HeaderKey {
///         public var contentType: HeaderKey { "Content-Type" }
///     }
///
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

/// this can be a tiny bit weird since it is infinite
/// ie: key.contentType.contentType.contentType
///
/// however, we're not using them that way.
///
///
/// They are utilized dynamically
extension HeaderKey {
    public var contentType: HeaderKey { "Content-Type" }
    public var authorization: HeaderKey { "Authorization" }
    public var accept: HeaderKey { "Accept" }
}

