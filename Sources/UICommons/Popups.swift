#if canImport(UIKit)

import UIKit
import Foundation

open class ErrorPopup: MessagePopup {
    public let error: Error

    public required init(_ error: Error) {
        self.error = error
        super.init(error.display)
    }

    public required init(_ message: String) {
        self.error = message
        super.init(message)
    }

    open override func setup() {
        super.setup()

        backgroundColor = ErrorPopup.appearance().backgroundColor ?? .systemGray
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public static func launch(file: String = #fileID,
                              line: Int = #line,
                              function: String = #function,
                              with error: Error) {
        Log.error(fileID: file, line: line, function: function, error)
        let popup = Self.init(error.display)
        let show = popup.show(file: file, line: line)
        let hide = popup.hide(file: file, line: line)
        show.completion(hide.delay(1.8).commit).commit()
    }
}

public final class Closer {
    private let desc: String
    private let function: () -> Void
    public init(
        file: String,
        line: Int,
        call function: @escaping () -> Void
    ) {
        self.desc = "\(file)[\(line)]"
        self.function = function
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let existing = self else { return }
            Log.warn("possibly detached loading closer: \(existing.desc)")
        }

    }

    public func callAsFunction() {
        function()
    }
}

open class MessagePopup: Popup {
    public let message: String
    public private(set) lazy var label: UILabel = Builder(UILabel.init)
        .numberOfLines(0)
        .font(.helvetica(18))
        .textAlignment(.center)
        .adjustsFontSizeToFitWidth(true)
        .textColor(.white)
        .text(self.message)
        .make()

    public required init(_ message: String) {
        self.message = message
        super.init()
        setup()

        layoutIfNeeded()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setup() {
        addSubview(label)
        pin(label, to: .top, 20)
        pin(label, to: .left, 30)
        pin(label, to: .bottom, -40)
        pin(label, to: .right, -30)

        let bottomBarHeight = 40.paddingBottom
        pin(.height, .greaterThanOrEqual, to: bottomBarHeight, priority: .defaultHigh)
        backgroundColor = MessagePopup.appearance().backgroundColor ?? .systemBlue
    }

    public static func launch(file: String = #file, line: Int = #line,
                       msg: String) {
        let popup = Self.init(msg)
        let show = popup.show(file: file, line: line)
        let hide = popup.hide(file: file, line: line)
        show.completion(hide.delay(1.5).commit).commit()
    }
}

open class Popup: UIView {
    public init() {
        super.init(frame: .sizing)
        setup()
        // todo: add swipe down, tap to keep alive, etc.
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        if #available(iOS 11.0, *) {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        layer.cornerRadius = 10
        addToWindow()
        listenKeyboard()
    }

    private var top: NSLayoutConstraint!

    private func addToWindow() {
        let keyboardHeight = KeyboardNotifications.shared
            .last
            .endVisibleHeight(in: keyWindow)

        self.alpha = 0
        keyWindow.addSubview(self)
        keyWindow.pin(self, edges: .sides)
        top = keyWindow.pin(self, .top, to: keyWindow, .bottom, -keyboardHeight)
        keyWindow.layoutIfNeeded()
    }

    public final func show(file: String = #file, line: Int = #line) -> AnimationBuilder {
        animation(0.65)
            .springDamping(0.9)
            .initialSpringVelocity(1)
            .animations {
                self.alpha = 1
                self.transform = .offset(y: -self.bounds.size.height)
            }
    }

    public final func hide(file: String = #file, line: Int = #line) -> AnimationBuilder {
        animation(0.25)
            .springDamping(2)
            .options(.curveEaseOut)
            .animations {
                self.alpha = 0
                self.transform = CGAffineTransform.identity.concatenating(.offset(y: keyWindow.bounds.halfHeight))
            }
            .completion(self.removeFromSuperview)
    }

    private func listenKeyboard() {
        KeyboardNotifications.shared.listen(with: self) { welf, update in
            let keyboardHeight = KeyboardNotifications.shared
                .last
                .endVisibleHeight(in: keyWindow)
            update.syncKeyboard.animations {
                welf.top.constant = -keyboardHeight
                welf.setNeedsLayout()
            } .commit()
        }
    }
}

#endif
