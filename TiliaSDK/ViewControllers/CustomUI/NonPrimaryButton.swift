//
//  NonPrimaryButton.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.03.2022.
//

import UIKit

class NonPrimaryButton: ButtonWithBackgroundColor {
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: super.intrinsicContentSize.width, height: 44)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
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
    setupBorderColor()
    titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
  }
  
  func setupBorderColor() {
    layer.borderColor = UIColor.borderColor.cgColor
  }
  
}
