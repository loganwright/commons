#if canImport(UIKit)

import UIKit

extension Array where Element == UIView {
    public var offscreenLeading: Block { positionOffscreenLeading }
    public var offscreenTrailing: Block { positionOffscreenTrailing }
    public var identity: Block { positionIdentity }

    public func positionOffscreenLeading() {
        enumerated().forEach { idx, v in
            let modifier = 1 + ((CGFloat(idx + 1) / CGFloat(self.count)) * 2)
            v.transform = .offset(x: -(keyWindow.bounds.width * modifier))
        }
    }

    public func positionOffscreenTrailing() {
        enumerated().forEach { idx, v in
            let modifier = 1 + ((CGFloat(idx + 1) / CGFloat(self.count)) * 2)
            v.transform = .offset(x: (keyWindow.bounds.width * modifier))
        }
    }

    public func positionIdentity() {
        set(each: \.transform, to: .identity)
    }

    public func slide(to: @escaping ([UIView]) -> Block) -> AnimationBuilder {
        animation(3).animations(to(self)).options(.curveEaseInOut)
    }
}

#endif
