//
//  PrimaryButtonWithStyle.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.05.2022.
//

import UIKit

final class PrimaryButtonWithStyle: PrimaryButton {
  
  enum Style {
    case titleAndImageCenter
    case imageAndTitleCenter
  }
  
  init(_ style: Style, frame: CGRect = .zero) {
    super.init(frame: frame)
    switch style {
    case .titleAndImageCenter:
      semanticContentAttribute = .forceRightToLeft
      imageEdgeInsets.left = 12
    case .imageAndTitleCenter:
      imageEdgeInsets.right = 12
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
