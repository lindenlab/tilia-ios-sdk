//
//  NonPrimaryButtonWithImage.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.05.2022.
//

import UIKit

final class NonPrimaryButtonWithImage: NonPrimaryButton {
  
  enum Style {
    case titleAndImageFill
    case titleAndImageCenter
    case imageAndTitleCenter
  }
  
  var placeholder: String? {
    didSet {
      setTitle(title(for: .normal), for: .normal)
    }
  }
    
  init(frame: CGRect = .zero, style: Style) {
    super.init(frame: frame)
    switch style {
    case .titleAndImageFill:
      contentHorizontalAlignment = .fill
    case .titleAndImageCenter:
      semanticContentAttribute = .forceRightToLeft
      imageEdgeInsets.left = 12
    case .imageAndTitleCenter:
      imageEdgeInsets.right = 12
      semanticContentAttribute = .forceLeftToRight
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setTitle(_ title: String?, for state: UIControl.State) {
    super.setTitle(title ?? placeholder, for: state)
    setTitleColor(title == nil ? .borderColor : .primaryTextColor, for: .normal)
  }
  
}
