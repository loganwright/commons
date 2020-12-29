#if os(iOS)
import UIKit

public class InsetTextField: UITextField {
    public var textInsets: UIEdgeInsets = .zero

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }
}
#endif
