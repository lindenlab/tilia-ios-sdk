//
//  NonPrimaryButtonWithImage.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.05.2022.
//

import UIKit

final class NonPrimaryButtonWithImage: NonPrimaryButton {
  
  enum Style {
    case titleAndImageInEdges
    case titleAndImageInCenter
    case imageAndTitleInCenter
  }
  
  var placeHolder: String? {
    didSet {
      guard title(for: .normal) == nil else { return }
      setTitle(nil, for: .normal)
      setTitleColor(.borderColor, for: .normal)
    }
  }
  
  let style: Style
  
  init(frame: CGRect = .zero, style: Style) {
    self.style = style
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    switch style {
    case .titleAndImageInEdges:
      contentHorizontalAlignment = .fill
    case .titleAndImageInCenter:
      imageEdgeInsets.left = titleLabel?.frame.width ?? 0 + 12
    case .imageAndTitleInCenter:
      imageEdgeInsets.right = 12
    }
  }
  
  override func setTitle(_ title: String?, for state: UIControl.State) {
    super.setTitle(title ?? placeHolder, for: state)
    guard placeHolder != nil else { return }
    setTitleColor(title == nil ? .borderColor : .primaryTextColor, for: .normal)
  }
  
}
