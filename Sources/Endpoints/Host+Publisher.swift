#if canImport(Combine)
import Combine

extension Base {
    public var publisher: BasePublisher { BasePublisher(self) }
}

public class BasePublisher: Publisher {
    public typealias Output = NetworkResponse
    public typealias Failure = Error

    public let base: Base

    public init(_ base: Base) {
        self.base = base
    }

    public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        let subscription = Subscription(subscriber: subscriber)
        subscriber.receive(subscription: subscription)

        base.on.result { result in
            switch result {
            case .success(let resp):
                let _ = subscriber.receive(resp)
                subscriber.receive(completion: .finished)
            case .failure(let err):
                subscriber.receive(completion: .failure(err))
            }
        }.send()
    }
}

extension BasePublisher {
    public final class Subscription<S: Subscriber>
    where S.Input == Output, S.Failure == Failure {
        private var subscriber: S?

        public init(subscriber: S) {
            self.subscriber = subscriber
        }
    }
}

extension BasePublisher.Subscription: Cancellable {
    public func cancel() {
        subscriber = nil
    }
}

extension BasePublisher.Subscription: Subscription {
    public func request(_ demand: Subscribers.Demand) {
        // ignoring command, single val
    }
}
#endif
