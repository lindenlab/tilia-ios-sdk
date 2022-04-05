//
//  PrimaryButton.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 28.03.2022.
//

import UIKit

final class PrimaryButton: UIButton {
  
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
    setBackgroundImage(UIColor.primaryColor.image(), for: .normal)
    layer.cornerRadius = 6
    clipsToBounds = true
    titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    isExclusiveTouch = true
  }
  
}
