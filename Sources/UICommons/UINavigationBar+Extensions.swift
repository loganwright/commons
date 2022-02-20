#if canImport(UIKit)
import UIKit

extension UINavigationController {
    public func hideNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for:.default)
        navigationBar.shadowImage = UIImage()
        navigationBar.layoutIfNeeded()
    }
}
#endif
