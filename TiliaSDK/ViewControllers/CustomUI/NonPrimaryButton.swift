//
//  NonPrimaryButton.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.03.2022.
//

import UIKit

final class NonPrimaryButton: UIButton {
  
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

private extension NonPrimaryButton {
  
  func setup() {
    setTitleColor(.primaryTextColor, for: .normal)
    setBackgroundImage(UIColor.backgroundColor.image(), for: .normal)
    layer.cornerRadius = 6
    layer.borderWidth = 1
    layer.borderColor = UIColor.borderColor.cgColor
    clipsToBounds = true
    titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    isExclusiveTouch = true
  }
  
}
