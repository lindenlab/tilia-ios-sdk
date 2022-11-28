//
//  NonPrimaryButton.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.03.2022.
//

import UIKit

final class NonPrimaryButton: Button {
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: super.intrinsicContentSize.width, height: 44)
  }
  
  override init(style: Button.Style? = nil, frame: CGRect = .zero) {
    super.init(style: style, frame: frame)
    setup()
    setupBorderColor()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
    setupBorderColor()
  }
  
}

// MARK: - Private Methods

private extension NonPrimaryButton {
  
  func setup() {
    setTitleColor(.primaryTextColor, for: .normal)
    setBackgroundColor(.backgroundColor, for: .normal)
    setBackgroundColor(.borderColor, for: .disabled)
    setBackgroundColor(.borderColor, for: .highlighted)
    layer.cornerRadius = 6
    layer.borderWidth = 1
    titleLabel?.font = .boldSystemFont(ofSize: 16)
  }
  
  func setupBorderColor() {
    layer.borderColor = UIColor.borderColor.cgColor
  }
  
}
