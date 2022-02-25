import Foundation

public var async: Async { Async() }

public struct Async {
    public func main(execute work: @escaping () -> Void) {
        DispatchQueue.main.async(execute: work)
    }
    
    public func global(execute work: @escaping () -> Void) {
        DispatchQueue.global().async(execute: work)
    }
    
    public func after(_ delay: TimeInterval,
                      on queue: DispatchQueue? = nil,
                      execute work: @escaping () -> Void) {
        let q = queue ?? OperationQueue.current?.underlyingQueue ?? .main
        q.asyncAfter(deadline: .now() + delay, execute: work)
    }
}

extension DispatchGroup {
    public func onComplete(_ block: @escaping () -> Void) {
        async.global {
            self.wait()
            async.main(execute: block)
        }
    }
}
