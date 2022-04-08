//
//  TextViewWithLink.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.03.2022.
//

import UIKit

protocol TextViewWithLinkDelegate: AnyObject {
  func textViewWithLink(_ textView: TextViewWithLink, didPressOn link: String)
}

final class TextViewWithLink: UITextView {
  
  typealias TextData = (text: String, links: [String])
  
  private static let hyperlinkTapUrl = URL(string: "hyperlink_tap_url")!
  
  weak var linkDelegate: TextViewWithLinkDelegate?
  
  var textData: TextData = ("", []) {
    didSet {
      setTextData()
    }
  }
  
  var linkColor: UIColor = .buttonColor {
    didSet {
      updateLinkAttributes()
    }
  }
  
  override var font: UIFont? {
    didSet {
      setTextData()
    }
  }
  
  override var textColor: UIColor? {
    didSet {
      setTextData()
    }
  }
  
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Returns `false` so the user can't copy, paste, etc
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    return false
  }
  
  /// Disable double-tap to select text
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if let tapGesture = gestureRecognizer as? UITapGestureRecognizer, tapGesture.numberOfTapsRequired > 1 {
      return false
    } else {
      return true
    }
  }
  
  /// Disable text selection and actions while still allowing `isSelectable = true` to enable link tapping
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    guard let closestPosition = closestPosition(to: point),
          let range = tokenizer.rangeEnclosingPosition(closestPosition, with: .character, inDirection: .layout(.left)) else { return false }
    let startIndex = offset(from: beginningOfDocument, to: range.start)
    return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
  }
  
}

// MARK: - UITextFieldDelegate

extension TextViewWithLink: UITextViewDelegate {
  
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    let link = textView.attributedText.attributedSubstring(from: characterRange).string
    linkDelegate?.textViewWithLink(self, didPressOn: link)
    return false
  }
  
}

// MARK: - Private Methods

private extension TextViewWithLink {
  
  func setup() {
    clipsToBounds = false
    isEditable = false
    isSelectable = true
    isScrollEnabled = false
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false
    textContainerInset = .zero
    self.textContainer.lineFragmentPadding = 0
    setContentHuggingPriority(.required, for: .vertical)
    setContentCompressionResistancePriority(.required, for: .vertical)
    dataDetectorTypes = []
    delegate = self
    isExclusiveTouch = true
  }
  
  func updateLinkAttributes() {
    linkTextAttributes = [.foregroundColor: linkColor, .underlineStyle: NSUnderlineStyle.single.rawValue]
  }
  
  func setTextData() {
    updateLinkAttributes()
    let font = self.font ?? .systemFont(ofSize: 16)
    let textColor = self.textColor ?? .titleColor
    let attributedText = NSMutableAttributedString(string: textData.text, attributes: [.font: font, .foregroundColor: textColor])
    textData.links.forEach { link in
      let nonBreakingLinkText = link.replacingOccurrences(of: " ", with: "\u{00a0}")
      let textWithNonBreakingLink = textData.text.replacingOccurrences(of: link, with: nonBreakingLinkText)
      if let range = textWithNonBreakingLink.range(of: nonBreakingLinkText).map({ NSRange($0, in: textWithNonBreakingLink) }) {
        attributedText.addAttributes([.link: Self.hyperlinkTapUrl], range: range)
      }
    }
    self.attributedText = attributedText
  }
  
}
