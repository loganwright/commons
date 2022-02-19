#if canImport(UIKit)
import UIKit
import Commons

public final class KeyboardNotifications: NSObject {
    public static func boot() {
        self.shared = KeyboardNotifications()
    }
    /// forcing the fail if boot forgets because otherwise we don't know about the current keyboard
    /// status on first check (if it's already showing)
    public private(set) static var shared: KeyboardNotifications! = nil

    public private(set) var last: KeyboardUpdate = .init(
        begin: .zero, end: .zero, duration: 0, options: []
    )

    /// garbage collected memory management
    /// be aware of any closures that might be retaining an object longer
    ///
    /// where necessary, call `.remove(listenersFor: )` to force a release
    @ThreadSafe private(set) var listeners: [(ob: Weak<AnyObject>, listener: (KeyboardUpdate) -> Void)]


    public func listen(with ob: AnyObject, _ listener: @escaping (KeyboardUpdate) -> Void) {
        listeners.flush(whereNil: \.ob.wrappedValue)
        listeners.append((Weak(ob), listener))
    }

    public func listen<A: AnyObject>(
        with ob: A,
        _ listener: @escaping (A, KeyboardUpdate
    ) -> Void) {
        listen(with: ob as AnyObject) { [weak ob] message in
            guard let welf = ob else { return }
            listener(welf, message)
        }
    }

    public func remove(listenersFor ob: AnyObject) {
        listeners.flush(where: \.ob.wrappedValue, matches: ob)
    }

    private override init() {
        self.listeners = []
        super.init()
        startObserving()
    }

    private func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

    }

    @objc private func keyboardWillChange(_ note: Notification) {
        listeners.flush(whereNil: \.ob.wrappedValue)
        let message = note.keyboardAnimation
        self.last = message
        listeners.pass(each: \.listener, arg: message)
    }
}

// MARK: Update

extension KeyboardNotifications {
    public struct KeyboardUpdate {
        public var isVisibleInWindow: Bool {
            endVisibleHeight(in: keyWindow) > 0
        }

        public enum Event {
            case change, appear, disappear
        }

        public let begin: CGRect
        public let end: CGRect
        public let duration: TimeInterval
        public let options: UIView.AnimationOptions

        public var event: Event {
            let startsOnScreen = keyWindow.bounds.contains(begin)
            let endsOnScreen = keyWindow.bounds.contains(end)

            if startsOnScreen && endsOnScreen {
                return .change
            } else if endsOnScreen {
                return .appear
            } else if startsOnScreen {
                return .disappear
            } else {
                Log.warn("undefined keyboard behavior")
                /// would mean keyboard never appears?
                /// maybe impossible
                return .change
            }
        }

        public var syncKeyboard: AnimationBuilder {
            animation(duration).options(options)
        }

        public func endVisibleHeight(in space: UICoordinateSpace) -> CGFloat {
            /// todo: be more aware of sizing in how it fits, for now
            /// I think it's fine
            guard end != .zero else { return 0 }
            return space.bounds.height - keyWindow.convert(end, to: space).minY
        }
    }
}

extension Notification {
    fileprivate var keyboardAnimation: KeyboardNotifications.KeyboardUpdate {
        .init(
            begin: keyboardBegin,
            end: keyboardEnd,
            duration: keyboardAnimationDuration,
            options: keyboardAnimationOptions
        )
    }

    func force<T>(key: AnyHashable, as: T.Type = T.self) -> T {
        return userInfo![key] as! T
    }

    private var keyboardBegin: CGRect! {
        return force(key: UIResponder.keyboardFrameBeginUserInfoKey)
    }

    private var keyboardEnd: CGRect! {
        return force(key: UIResponder.keyboardFrameEndUserInfoKey)
    }

    private var keyboardAnimationDuration: TimeInterval! {
        return force(key: UIResponder.keyboardAnimationDurationUserInfoKey)
    }

    private var keyboardAnimationOptions: UIView.AnimationOptions! {
        let raw = force(key: UIResponder.keyboardAnimationCurveUserInfoKey,
                      as: UInt.self)
        let curve = UIView.AnimationOptions(rawValue: raw << 16)
        return curve
    }
}
#endif
