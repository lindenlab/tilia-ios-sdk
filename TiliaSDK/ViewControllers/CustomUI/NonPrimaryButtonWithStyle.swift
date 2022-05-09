//
//  NonPrimaryButtonWithStyle.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.05.2022.
//

import UIKit

final class NonPrimaryButtonWithStyle: NonPrimaryButton {
  
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
  
  private let style: Style
  
  init(_ style: Style, frame: CGRect = .zero) {
    self.style = style
    super.init(frame: frame)
    switch style {
    case .titleAndImageFill:
      contentHorizontalAlignment = .left
      semanticContentAttribute = .forceRightToLeft
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
  
  override func layoutSubviews() {
    super.layoutSubviews()
    guard style == .titleAndImageFill else { return }
    let contentHorizontalInset = contentEdgeInsets.left + contentEdgeInsets.right
    let titleLabelWidth = titleLabel?.frame.width ?? 0
    let imageViewWidth = imageView?.frame.width ?? 0
    let inset = frame.width - contentHorizontalInset - titleLabelWidth - imageViewWidth
    imageEdgeInsets.left = inset
  }
  
  override func setTitle(_ title: String?, for state: UIControl.State) {
    super.setTitle(title ?? placeholder, for: state)
    setTitleColor(title == nil ? .borderColor : .primaryTextColor, for: .normal)
    titleLabel?.font = title == nil ? .systemFont(ofSize: 16) : .boldSystemFont(ofSize: 16)
  }
  
}
