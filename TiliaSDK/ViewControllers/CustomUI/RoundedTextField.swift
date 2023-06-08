//
//  RoundedTextField.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 09.05.2022.
//

import UIKit

final class RoundedTextField: UITextField {
  
  var isReturnKeyEnabled: Bool?
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: super.intrinsicContentSize.width, height: 44)
  }
  
  override var placeholder: String? {
    didSet {
      setupAttributedPlaceholder()
    }
  }
  
  override var hasText: Bool {
    return isReturnKeyEnabled ?? super.hasText
  }
  
  override var isEnabled: Bool {
    didSet {
      backgroundColor = isEnabled ? .backgroundColor : .backgroundDarkerColor
      textColor = isEnabled ? .primaryTextColor : .tertiaryTextColor
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    let rightInset = rightView.map { $0.frame.width + 8 } ?? 16
    return bounds.inset(by: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: rightInset))
  }
  
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    let rightInset = rightView.map { $0.frame.width + 8 } ?? 16
    return bounds.inset(by: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: rightInset))
  }
  
  override func caretRect(for position: UITextPosition) -> CGRect {
    return inputView == nil ? super.caretRect(for: position) : .zero
  }
  
  override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
    return inputView == nil ? super.selectionRects(for: range) : []
  }
  
  override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    let rect = super.rightViewRect(forBounds: bounds)
    let x = bounds.width - rect.width - 8
    return CGRect(x: x, y: rect.minY, width: rect.width, height: rect.height)
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
    setupBorderColor()
  }
  
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard !isUserInteractionEnabled || !isEnabled, let rightView = rightView else {
      return super.hitTest(point, with: event)
    }
    let pointInSubview = rightView.convert(point, from: self)
    if rightView.point(inside: pointInSubview, with: event) {
      return rightView
    } else {
      return super.hitTest(point, with: event)
    }
  }
  
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    guard inputView != nil else {
      return super.canPerformAction(action, withSender: sender)
    }
    switch action {
    case #selector(cut(_:)): return false
    case #selector(copy(_:)): return false
    case #selector(paste(_:)): return false
    case #selector(select(_:)): return false
    case #selector(selectAll(_:)): return false
    case #selector(delete(_:)): return false
    default: return super.canPerformAction(action, withSender: sender)
    }
  }
  
}

// MARK: - Private Methods

private extension RoundedTextField {
  
  func setup() {
    autocorrectionType = .no
    backgroundColor = .backgroundColor
    textColor = .primaryTextColor
    font = .systemFont(ofSize: 16)
    layer.cornerRadius = 6
    layer.borderWidth = 1
    setupBorderColor()
  }
  
  func setupBorderColor() {
    layer.borderColor = UIColor.borderColor.cgColor
  }
  
  func setupAttributedPlaceholder() {
    guard let placeholder = placeholder else { return }
    let attributes: [NSAttributedString.Key : Any] = [
      .foregroundColor: UIColor.borderColor,
      .font: UIFont.systemFont(ofSize: 16)
    ]
    attributedPlaceholder = NSAttributedString(string: placeholder,
                                               attributes: attributes)
  }
  
}
