//
//  DividerView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

final class DividerView: UIView {
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.layoutFittingExpandedSize.width, height: 1)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .dividerColor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
