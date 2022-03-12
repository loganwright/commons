import Foundation
import Commons

/// currently here as a reference, not sure how to genericize yet
/// this middleware sits on all authorized requests
/// upon receiving an error for an expired token it attempts
/// another request using the same responder chain
///
/// MUST go to front of middleware, if others
/// are ahead of it, they may trigger with the error before
/// the refresh
struct RefreshMiddleware: Middleware {

    let base: Root
    let refreshRequest: () -> Root
    let updateAuthHeaders: (Root, JSON) -> Void

    init(_ base: Root,
         refreshRequest: @escaping () -> Root,
         updateAuthHeaders: @escaping (Root, JSON) -> Void) {
        self.base = base
        self.refreshRequest = refreshRequest
        self.updateAuthHeaders = updateAuthHeaders
    }

    // MARK: Middleware

    // TODO: can I move this to a private object and pass through in this file
    // so that it's not exposed
    func handle(_ result: Result<NetworkResponse, Error>,
                next: @escaping NetworkCompletion) {
         //todo: are there somoe potential threading issues here?
        // maybe setup some sort of operation queue
        switch result {
        // detect unauthorized expired
        case .failure(let err as NSError) where err.code == 401:
            Log.info("unauthorized request, attempting refresh")
            // attempt a refresh
            Log.info("refresh.started: \(base.expandedUrl)")

            refreshRequest()
                .on.success(retry(withRefreshResult:))
                .on.error { error in
                    next(.failure(error))
                }
                .send()
        default:
            // all other failures or success pass down chain
            next(result)
        }
    }

    private func retry(withRefreshResult result: JSON) {
        updateAuthHeaders(base, result)
        base.drop(middleware: {
            $0 is RefreshMiddleware
        })
        .send()
    }
}


extension Root {
//    func using(_ auth: Auth) -> Self {
//        let refresh = RefreshMiddleware(self, auth)
//        return middleware(refresh)
//            .guard(!auth.access.isEmpty, else: "user not authorized")
//            .header.authorization("Bearer \(auth.access)")
//            as! Self
//    }
}
