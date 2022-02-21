import SwiftUI

extension View {
    public func fillParentBounds(width: Bool = true, height: Bool = true) -> some View {
        frame(maxWidth: width ? .infinity : nil, maxHeight: height ? .infinity : nil)
    }
}
