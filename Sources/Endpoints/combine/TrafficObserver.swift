#if canImport(Combine)
import Combine
import Foundation
import Commons

/// a sort of monitor of ongoing and historical requests
/// not recommended for production in current state
public final class TrafficObserver<C: Client>: ObservableObject, Client {
    /// requests waiting for a response
    /// Key: an id assigned to the request
    /// Value: the request submitted
    @Published
    public var active: [String: URLRequest] = [:]
    /// requests that have already received a response
    
    // GOAL: workout a better system here, currently using `URLRequest` to avoid
    // capturing the Root object, need some sort of representative or model 
    @Published
    public var history: [(URLRequest, NetworkResult)] = []

    public let clientBuilder: () -> C
    public var client: C { clientBuilder() }

    /// a clientbuilder to wrap
    public init(_ client: @autoclosure @escaping () -> C) {
        self.clientBuilder = client
    }

    public func send(_ request: URLRequest, completion: @escaping NetworkCompletion) {
        let id = UUID().uuidString
        active[id] = request
        self.client.send(request) { resp in
            self.active[id] = nil
            self.history.append((request, resp))
            completion(resp)
        }
    }
}

extension TrafficObserver where C == URLSession {
    public static let `default` = TrafficObserver(URLSession(configuration: .default))
}

extension Root {
    public func client(_ observer: TrafficObserver<URLSession>, debugOnly: Bool) -> Self {
        if debugOnly, IS_PRODUCTION {
            return self
        } else {
            self.networkClient = observer
            return self
        }
    }
}
#endif
