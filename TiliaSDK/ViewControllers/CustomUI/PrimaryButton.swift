//
//  PrimaryButton.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 28.03.2022.
//

import UIKit

final class PrimaryButton: ButtonWithBackgroundColor {
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.layoutFittingExpandedSize.width, height: 48)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Private Methods

private extension PrimaryButton {
  
  func setup() {
    setTitleColor(.primaryButtonTextColor, for: .normal)
    setBackgroundColor(.primaryColor, for: .normal)
    setBackgroundColor(.primaryColor.withAlphaComponent(0.5), for: .disabled)
    setBackgroundColor(.primaryColor.withAlphaComponent(0.5), for: .highlighted)
    layer.cornerRadius = 6
    titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
  }
  
}
