import Foundation

public enum HTTPMethod: String, Codable, Equatable {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case connect = "CONNECT"
}

public struct HTTPMethods {
    internal static let instance = HTTPMethods()
    
    public var get: HTTPMethod = .get
    public var post: HTTPMethod = .post
    public var put: HTTPMethod = .put
    public var patch: HTTPMethod = .patch
    public var delete: HTTPMethod = .delete
    public var head: HTTPMethod = .head
    public var options: HTTPMethod = .options
    public var trace: HTTPMethod = .trace
    public var connect: HTTPMethod = .connect
}

extension String {
    var withTrailingSlash: String {
        if let url = URL(string: self),
            !url.pathExtension.isEmpty {
            return self
        }
        if hasSuffix("/") { return self }
        else { return self + "/" }
    }
}
