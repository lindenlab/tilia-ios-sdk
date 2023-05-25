//
//  CloseButton.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 18.05.2023.
//

import UIKit

final class CloseButton: NonPrimaryButton {
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: 30, height: 30)
  }
  
  override init(style: Button.Style? = nil, frame: CGRect = .zero) {
    super.init(style: style, frame: frame)
    setImage(.closeIcon?.withRenderingMode(.alwaysTemplate),
             for: .normal)
    imageView?.tintColor = .primaryTextColor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
