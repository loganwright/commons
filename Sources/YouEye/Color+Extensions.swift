import SwiftUI
#if canImport(UIKit)
import UIKit
typealias NSColor = UIColor
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    public var components: (r: Double, g: Double, b: Double, a: Double) {
        /// passing through UIColor because things like `Color.red`
        /// always return `nil` otherwise :/
        let comps = NSColor(self).cgColor.components ?? []
        return (
            comps[safe: 0] ?? 0,
            comps[safe: 1] ?? 0,
            comps[safe: 2] ?? 0,
            comps[safe: 3] ?? 0
        )
    }
}

extension Array {
    subscript(safe idx: Int) -> Element? {
        guard idx < count else { return nil }
        return self[idx]
    }
}

extension Color {
    public func mix(with other: Color, percent: Double) -> Color {
        let left = self.components
        let right = other.components
        let r = left.r + right.r - (left.r * percent)
        let g = left.g + right.g - (left.g * percent)
        let b = left.b + right.b - (left.b * percent)
        
        return Color(red: Double(r), green: Double(g), blue: Double(b))
    }
}
