//#if canImport(Combine)
//import Combine
//import Foundation
//import Commons
//
//public final class TrafficObserver<C: Client>: ObservableObject, Client {
//    @Published
//    public var active: [String: URLRequest] = [:]
//    @Published
//    public var history: [(URLRequest, NetworkResult)] = []
//    
//    public let client: C
//    public init(_ client: C) {
//        self.client = client
//    }
//    
//    public func send(_ request: URLRequest, completion: @escaping NetworkCompletion) {
//        let id = UUID().uuidString
//        active[id] = request
//        self.client.send(request) { resp in
//            self.active[id] = nil
//            self.history.append((request, resp))
//        }
//    }
//}
//
//extension TrafficObserver where C == URLSession {
//    public static let `defaultObserver`
//}
//#endif
