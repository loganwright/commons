import SwiftUI
#if canImport(UIKit)
import UIKit
typealias NSColor = UIColor
#elseif canImport(AppKit)
import AppKit
#endif

import Commons

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

// MARK: Hex

extension Color {
    public init(hex: String) {
        guard hex.hasPrefix("#"), hex.count == 7 else {
            fatalError("unexpected hex color format")
        }
        
        let cleanHex = hex.uppercased()
        let chars = Array(cleanHex)
        let rChars = chars[1...2]
        let gChars = chars[3...4]
        let bChars = chars[5...6]
        
        var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0;
        Scanner(string: .init(rChars)).scanHexInt64(&r)
        Scanner(string: .init(gChars)).scanHexInt64(&g)
        Scanner(string: .init(bChars)).scanHexInt64(&b)
        self = Color(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0
        )
    }
}
