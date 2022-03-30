//
//  RoundedButton.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.03.2022.
//

import UIKit

final class RoundedButton: UIButton {
  
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

private extension RoundedButton {
  
  func setup() {
    setTitleColor(.customBlack, for: .normal)
    setBackgroundImage(UIColor.white.image(), for: .normal)
    layer.cornerRadius = 6
    layer.borderWidth = 1
    layer.borderColor = UIColor.blackWithLightTransparency.cgColor
    clipsToBounds = true
    titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    isExclusiveTouch = true
  }
  
}
