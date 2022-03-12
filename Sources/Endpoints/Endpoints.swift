/// endpoint, also known as path, slug, ..
///
/// extend this to define paths you will reuse
/// across your api interaction
public struct Endpoint: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public let stringValue: String

    public init(stringLiteral s: String) {
        self.stringValue = s
    }
    
    public init(_ s: String) {
        self.stringValue = s
    }
}


