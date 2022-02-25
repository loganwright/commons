import Foundation

public enum HTTPMethod: String, Codable, Equatable {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

public struct HTTPMethods {
    static let group = HTTPMethods()
    
    public var get: HTTPMethod = .get
    public var post: HTTPMethod = .post
    public var put: HTTPMethod = .put
    public var patch: HTTPMethod = .patch
    public var delete: HTTPMethod = .delete
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
