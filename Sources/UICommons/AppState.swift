#if canImport(UIKit)
import UIKit

public unowned let keyWindow = UIApplication.shared.windows.first!

extension CGFloat {
    ///
    /// top notch: 47, bottom: line 34
    /// a little hacky, but it's the most consistent
    public var paddingTop: CGFloat {
        if #available(iOS 11.0, *) {
            return self + keyWindow.safeAreaInsets.top
        } else {
            return 20 // the info bar
        }
    }

    public var paddingBottom: CGFloat {
        if #available(iOS 11.0, *) {
            return self + keyWindow.safeAreaInsets.bottom
        } else {
            return 0
        }
    }

    public func ifSmall(use small: CGFloat) -> CGFloat {
        if self.paddingTop <= 20 {
            return small
        } else {
            return self
        }
    }
}

extension Int {
    /// a little hacky, but it's the most consistent
    public var paddingTop: CGFloat {
        CGFloat(self).paddingTop
    }

    /// bottom is 34 on swipe up devices
    public var paddingBottom: CGFloat {
        CGFloat(self).paddingBottom
    }

    public func ifSmall(use small: CGFloat) -> CGFloat {
        if 0.paddingTop <= 20 {
            return small
        } else {
            return CGFloat(self)
        }
    }
}

extension UIDevice {
    @available(iOS 11, *)
    public var hasPhysicalHomeButton: Bool {
        /// on iPhone X or phones w swipe instead of button, the tab bar seems taller and we position differently..
        /// we're detecting this by seeing if the window has insets that need to be accounted for
        return abs(keyWindow.safeAreaInsets.bottom) > 0
    }
}
extension UIDevice {
    @available(iOS 11, *)
    public var hasNotch: Bool {
        // 20 is the status bar, hacky, but ya, had to do it for some screens /sorry
        return abs(keyWindow.safeAreaInsets.top) > 20
    }
}

// Global Imports

@_exported import Commons
#endif
