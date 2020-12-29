#if os(iOS)
import Foundation
import UIKit

extension CGRect {
    public var center: CGPoint {
        .init(x: width / 2, y: height / 2)
    }
}

extension Int {
    public var radians: CGFloat {
        return CGFloat(self).toRadians
    }
}
extension CGFloat {
    public var toRadians: CGFloat {
        return CGFloat(Double(self) * (.pi / 180))
    }
    public var toDegrees: CGFloat {
        return self * CGFloat(180.0 / .pi)
    }
}

extension CGFloat {
    public var squared: CGFloat {
        return self * self
    }
}

extension CGPoint {
    public static var ones: CGPoint { .init(x: 1, y: 1) }
    
    public func angle(to point: CGPoint) -> CGFloat {
        let originX = point.x - self.x
        let originY = point.y - self.y
        let bearingRadians = atan2f(Float(originY), Float(originX))
        var bearingDegrees = CGFloat(bearingRadians).toDegrees
        while bearingDegrees < 0 {
            bearingDegrees += 360
        }
        return bearingDegrees
    }

    public func distanceToPoint(point: CGPoint) -> CGFloat {
        let distX = point.x - self.x
        let distY = point.y - self.y
        let distance = sqrt(distX.squared + distY.squared)
        return distance
    }
}

public func +=(left: inout CGPoint, right: CGPoint) {
    left.x += right.x
    left.y += right.y
}

public func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

public func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func +(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

public func -(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}

public func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}

public func avg(of numbers: CGFloat...) -> CGFloat {
    return numbers.reduce(0, +) / CGFloat(numbers.count)
}

public func circumferenceForRadius(_ radius: CGFloat) -> CGFloat {
    return radius * CGFloat(.pi * 2.0)
}

public func lengthOfArcForDegrees(degrees: CGFloat, radius: CGFloat) -> CGFloat {
    let circumference = circumferenceForRadius(radius)
    let percentage = degrees / 360.0
    return circumference * percentage
}

public func degreesForLengthOfArc(lengthOfArc: CGFloat, radius: CGFloat) -> CGFloat {
    let circumference = circumferenceForRadius(radius)
    let percentage = lengthOfArc / circumference
    return percentage * 360
}

public func pointWithCenter(center: CGPoint, radius: CGFloat, angleDegrees: CGFloat) -> CGPoint {
    let x = radius * cos(angleDegrees.toRadians) + center.x
    let y = radius * sin(angleDegrees.toRadians) + center.y
    return CGPoint(x: x, y: y)
}

extension CGRect {
    public var halfWidth: CGFloat {
        width / 2.0
    }

    public var halfHeight: CGFloat {
        height / 2.0
    }

    public var shortestEdge: CGFloat {
        return min(width, height)
    }

    public var longestEdge: CGFloat {
        return max(width, height)
    }
}

extension CGSize {
    public func scaledHeightAtFixedWidth(_ fixedWidth: CGFloat) -> CGFloat {
        let scale = height / width
        return fixedWidth * scale
    }

    public func scaledWidthAtFixedHeight(_ fixedHeight: CGFloat) -> CGFloat {
        let scale = width / height
        return fixedHeight * scale
    }
}

extension CGRect {
    public func inset(by: CGFloat) -> CGRect {
        return inset(by: .init(top: by, left: by, bottom: by, right: by))
    }
}

extension CGFloat {
    public static var ninetyDegrees: CGFloat { CGFloat(.pi / 2.0) }
}

struct Geometry {
    /// assuming a fill from 0-1.0 where 0 is 12 o'clock, 0.25 is 3 o'clock, and so on
    public static func convertToAngle(fill: Double) -> CGFloat {
        assert(0...1 ~= fill, "unsupported value, expected 0-1.0")
        let oneHundredEightyDegrees = Double.pi
        let ninetyDegrees = oneHundredEightyDegrees / 2.0
        let threeHundredSixtyDegrees = oneHundredEightyDegrees * 2.0

        /// drawing normally starts at 3 o'clock, we need to offset to draw from 12 o'clock
        let top = -ninetyDegrees
        let converted = fill * threeHundredSixtyDegrees
        return CGFloat(top + converted)
    }
}


extension CGRect {
    /// some view layouts crash if we raw w cgrect.zero, so this is better
    public static var sizing: CGRect { .init(x: 0, y: 0, width: 160, height: 160) }
}
#endif
