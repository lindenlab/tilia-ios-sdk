//
//  TextViewWithLink.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.03.2022.
//

import UIKit
import Combine

final class TextViewWithLink: UITextView {
  
  typealias TextData = (text: String, links: [String])
  
  private static let hyperlinkTapUrl = URL(string: "hyperlink_tap_url")!
  
  let linkPublisher = PassthroughSubject<String, Never>()
  
  var textData: TextData = ("", []) {
    didSet {
      setTextData()
    }
  }
  
  var linkColor: UIColor = .blue {
    didSet {
      updateLinkAttributes()
    }
  }
  
  var mainTextColor: UIColor = .black {
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

extension TextViewWithLink: UITextViewDelegate {
  
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    let link = textView.attributedText.attributedSubstring(from: characterRange).string
    linkPublisher.send(link)
    return false
  }
  
}

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
  }
  
  func updateLinkAttributes() {
    linkTextAttributes = [.foregroundColor: linkColor, .underlineStyle: NSUnderlineStyle.single.rawValue]
  }
  
  func setTextData() {
    updateLinkAttributes()
    let attributedText = NSMutableAttributedString(string: textData.text, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: mainTextColor])
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
