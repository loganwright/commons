#if canImport(UIKit)

import Foundation
import UIKit
import Commons

// MARK: Drawing

extension UIImage {
    public static func makeCircle(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            Log.warn("unable to make graphics context for circle graphic render")
            return nil
        }

        context.setFillColor(.convert(backgroundColor))
        context.setStrokeColor(.convert(.clear))
        let bounds = CGRect(origin: .zero, size: size)
        context.addEllipse(in: bounds)
        context.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    static func makeTriangle(
        a: CGPoint,
        b: CGPoint,
        c: CGPoint,
        in container: CGSize,
        color: UIColor
    ) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(container, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            Log.warn("unable to make graphics context for circle graphic render")
            return nil
        }

        context.setFillColor(color.cgColor)
        context.setStrokeColor(UIColor.clear.cgColor)
        //
        context.move(to: a)
        context.addLine(to: b)
        context.addLine(to: c)
        context.addLine(to: a)
        context.fillPath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

#endif
