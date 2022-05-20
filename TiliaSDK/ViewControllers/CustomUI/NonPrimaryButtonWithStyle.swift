//
//  NonPrimaryButtonWithStyle.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.05.2022.
//

import UIKit

final class NonPrimaryButtonWithStyle: NonPrimaryButton {
  
  enum Style {
    case titleAndImageCenter
    case imageAndTitleCenter
  }
  
  init(style: Style, frame: CGRect = .zero) {
    super.init(frame: frame)
    switch style {
    case .titleAndImageCenter:
      semanticContentAttribute = .forceRightToLeft
      imageEdgeInsets.right = -8
    case .imageAndTitleCenter:
      imageEdgeInsets.left = -8
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
    super.setTitleColor(color, for: state)
    if state == .normal, let color = color {
      imageView?.tintColor = color
    }
  }
  
}
