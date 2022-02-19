import Foundation

/// useful in testing a la failed network,
/// or to trigger refresh
///
/// maybe also more practical ones
public struct ReplaceResponse: Middleware {
    public let replacement: NetworkResult
    private let shouldReplace: (NetworkResult) -> Bool
    
    public init(with replacement: NetworkResult, when should: @escaping (NetworkResult) -> Bool = { _ in true }) {
        self.replacement = replacement
        self.shouldReplace = should
    }
    
    public func handle(_ result: Result<NetworkResponse, Error>, next: @escaping (Result<NetworkResponse, Error>) -> Void) {
        if shouldReplace(result) {
            next(replacement)
        } else {
            next(result)
        }
    }
}

extension ReplaceResponse {
    public static func respondOffline(timesToFail: Int = 1) -> ReplaceResponse {
        var timesFailed = 0
        return ReplaceResponse(with: .failure(.noNetwork)) { _ in
            defer { timesFailed += 1 }
            return timesFailed < timesToFail
        }
    }
}

// MARK: No Network Error

extension Error where Self == NSError {
    public static var noNetwork: Self {
        NSError(
            domain: NSURLErrorDomain,
            code: NoNetworkErrorCode,
            userInfo: [NSLocalizedDescriptionKey: "not connected to network"]
        )
    }
}
