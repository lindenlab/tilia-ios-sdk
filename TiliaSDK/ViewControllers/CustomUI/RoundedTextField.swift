//
//  RoundedTextField.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 09.05.2022.
//

import UIKit

final class RoundedTextField: UITextField {
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: super.intrinsicContentSize.width, height: 44)
  }
  
  override var placeholder: String? {
    didSet {
      setupAttributedPlaceholder()
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
    return bounds.inset(by: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
  }
  
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
  }
  
  override func caretRect(for position: UITextPosition) -> CGRect {
    return inputView == nil ? super.caretRect(for: position) : .zero
  }
  
  override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
    return inputView == nil ? super.selectionRects(for: range) : []
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
    setupBorderColor()
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
