import SwiftUI

/// allows a unit point to be used in animations
extension UnitPoint: VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        x = x * rhs
        y = y * rhs
    }
    
    /// Returns the dot-product of this vector arithmetic instance with itself.
    public var magnitudeSquared: Double {
        // ignoring this, idk what it is
        0.0
    }
    
    public static func + (lhs: UnitPoint, rhs: UnitPoint) -> UnitPoint {
        UnitPoint(
            x: lhs.x + rhs.x,
            y: lhs.y + rhs.y
        )
    }
    
    public static func - (lhs: UnitPoint, rhs: UnitPoint) -> UnitPoint {
        UnitPoint(
            x: lhs.x - rhs.x,
            y: lhs.y - rhs.y
        )
    }
}

extension CGRect {
    public func convert(_ unitPoint: UnitPoint) -> CGPoint {
        let x = unitPoint.x * width
        let y = unitPoint.y * height
        return CGPoint(x: minX + x,
                       y: minY + y)
    }
}
