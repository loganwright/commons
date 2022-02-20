#if canImport(UIKit)

import UIKit

extension UIView {
    public func snapshotView() -> UIView {
        resizableSnapshotView(
            from: bounds,
            afterScreenUpdates: true,
            withCapInsets: .zero
        )!
    }
}

extension UIView {
    public func snapshotImage() -> UIImage {
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

#endif
