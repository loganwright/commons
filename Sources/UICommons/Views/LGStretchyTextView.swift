#if canImport(UIKit)

import UIKit
import Commons

// MARK: Container

public class StretchyTextViewContainer: UIView, LGStretchyTextViewDelegate {
    private var height: NSLayoutConstraint! = nil
    public let textView = LGStretchyTextView()
    private let textViewInsets = UIEdgeInsets(top: 20, left: 28, bottom: 20, right: 28)
    public let placeholder = UILabel()

    /// sometimes the patterns aren't clear, when using delegates vs functions like this..
    /// I will try to clarify as I go
    public var onUpdates: (LGStretchyTextView) -> Void = { _ in  }
    public var onShouldReturn: (LGStretchyTextView) -> Bool = { _ in true }

    public func set(maxHeightPortrait: CGFloat) {
        textView.maxHeightPortrait = maxHeightPortrait - (textViewInsets.top + textViewInsets.bottom)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        setupTextView()
        setupPlaceholder()

        layer.cornerRadius = 16
        backgroundColor = "#F3F5F9".uicolor
        update()
    }

    private func setupTextView() {
        textView.stretchyTextViewDelegate = self
        addSubview(textView)
        pin(textView, to: .top, textViewInsets.top)
        pin(textView, to: .left, textViewInsets.left)
        pin(textView, to: .bottom, -textViewInsets.bottom)
        pin(textView, to: .right, -textViewInsets.right)
        height = pin(.height, to: 60)

        textView.returnKeyType = .done
        textView.textContainerInset = .zero
        textView.backgroundColor = .clear
    }

    private func setupPlaceholder() {
        textView.addSubview(placeholder)
        placeholder.isUserInteractionEnabled = false
        placeholder.text = "Enter text..."
    }

    // MARK:

    public override func layoutSubviews() {
        super.layoutSubviews()
        positionPlaceholder()
    }

    private func positionPlaceholder() {
        let caretRect = textView.caretRect(for: textView.beginningOfDocument)
        var insets = UIEdgeInsets.zero
        insets.left = caretRect.maxX + 2
        placeholder.frame = textView.bounds.inset(by: insets)
    }
    
    private func update() {
        positionPlaceholder()
        placeholder.font = textView.font
        placeholder.textColor = textView.textColor?.withAlphaComponent(0.5)
        placeholder.isHidden = !textView.text.isEmpty

        onUpdates(textView)
    }

    public func stretchyTextViewDidChangeSize(_ textView: LGStretchyTextView) {
        let textViewHeight = textView.bounds.height
        let targetConstant = textViewHeight + textViewInsets.top + textViewInsets.bottom
        height.constant = targetConstant
        layoutIfNeeded()
    }

    public func stretchyTextViewDidChangeContents(_ textView: LGStretchyTextView) {
        update()
    }

    public func stretchyTextViewShouldReturn(_ textView: LGStretchyTextView) -> Bool {
        return onShouldReturn(textView)
    }
}

// MARK: Text View

@objc public protocol LGStretchyTextViewDelegate {
    func stretchyTextViewDidChangeSize(_ textView: LGStretchyTextView)
    func stretchyTextViewDidChangeContents(_ textView: LGStretchyTextView)
    @objc optional func stretchyTextViewShouldReturn(_ textView: LGStretchyTextView) -> Bool
}

public class LGStretchyTextView : UITextView, UITextViewDelegate {

    // MARK: Delegate

    public weak var stretchyTextViewDelegate: LGStretchyTextViewDelegate?

    // MARK: Public Properties

    public var maxHeightPortrait: CGFloat = 400
    public var maxHeightLandScape: CGFloat = 60
    public var maxHeight: CGFloat {
        get {
            Log.warn("if we're sticking w storyboards, we lose refs to thesee")
            // only portrait
            return maxHeightPortrait
//            return keyWindowScene.interfaceOrientation.isPortrait
//                ? maxHeightPortrait
//                : maxHeightLandScape
        }
    }

    // MARK: Private Properties

    private var maxSize: CGSize {
        get {
            return CGSize(width: self.bounds.width, height: self.maxHeightPortrait)
        }
    }

    private let sizingTextView = UITextView()

    // MARK: Property Overrides

    public override var contentSize: CGSize {
        didSet {
            resize()
        }
    }

    public override var font: UIFont! {
        didSet {
            sizingTextView.font = font
        }
    }

    public override var textContainerInset: UIEdgeInsets {
        didSet {
            sizingTextView.textContainerInset = textContainerInset
        }
    }

    // MARK: Initializers

    public override init(frame: CGRect = .sizing, textContainer: NSTextContainer? = nil) {
        super.init(frame: frame, textContainer: textContainer);
        setup()
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    internal func setup() {
        font = UIFont.systemFont(ofSize: 17.0)
        textContainerInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        delegate = self
    }

    // MARK: Sizing

    public func resize() {
        bounds.size.height = self.targetHeight()
        layoutIfNeeded()
        stretchyTextViewDelegate?.stretchyTextViewDidChangeSize(self)
    }

    public func targetHeight() -> CGFloat {

        /*
        There is an issue when calling `sizeThatFits` on self that results in really weird drawing issues with aligning line breaks ("\n").  For that reason, we have a textView whose job it is to size the textView. It's excess, but apparently necessary.  If there's been an update to the system and this is no longer necessary, or if you find a better solution. Please remove it and submit a pull request as I'd rather not have it.
        */

        sizingTextView.text = self.text
        let targetSize = sizingTextView.sizeThatFits(maxSize)
        let targetHeight = targetSize.height
        let maxHeight = self.maxHeight
        return targetHeight < maxHeight ? targetHeight : maxHeight
    }

    // MARK: Alignment

    public func align() {
        guard let end = self.selectedTextRange?.end else { return }
        let caretRect = self.caretRect(for: end)

        let topOfLine = caretRect.minY
        let bottomOfLine = caretRect.maxY

        let contentOffsetTop = self.contentOffset.y
        let bottomOfVisibleTextArea = contentOffsetTop + self.bounds.height

        /*
        If the caretHeight and the inset padding is greater than the total bounds then we are on the first line and aligning will cause bouncing.
        */

        let caretHeightPlusInsets = caretRect.height + self.textContainerInset.top + self.textContainerInset.bottom
        if caretHeightPlusInsets < self.bounds.height {
            var overflow: CGFloat = 0.0
            if topOfLine < contentOffsetTop + self.textContainerInset.top {
                overflow = topOfLine - contentOffsetTop - self.textContainerInset.top
            } else if bottomOfLine > bottomOfVisibleTextArea - self.textContainerInset.bottom {
                overflow = (bottomOfLine - bottomOfVisibleTextArea) + self.textContainerInset.bottom
            }
            self.contentOffset.y += overflow
        }
    }

    // MARK: UITextViewDelegate

    public func textViewDidChangeSelection(_ textView: UITextView) {
        self.align()
    }

    public func textViewDidChange(_ textView: UITextView) {
        self.stretchyTextViewDelegate?.stretchyTextViewDidChangeContents(self)
    }

    public func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        guard text ==  "\n" else { return true }
        return self.stretchyTextViewDelegate?.stretchyTextViewShouldReturn?(self) ?? true
    }
}

#endif
