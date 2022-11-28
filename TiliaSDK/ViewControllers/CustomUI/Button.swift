//
//  Button.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 05.04.2022.
//

import UIKit

class Button: UIButton {
  
  enum Style {
    case titleAndImageCenter
    case imageAndTitleCenter
  }
  
  private var backgroundColorsByState: [UInt: UIColor] = [:]
  
  let style: Style?
  
  override var backgroundColor: UIColor? {
    get {
      return super.backgroundColor
    }
    set {
      setBackgroundColor(newValue, for: .normal)
    }
  }
  
  override var isHighlighted: Bool {
    didSet {
      setupBackgroundColor()
      titleColor(for: state).map { imageView?.tintColor = $0 }
    }
  }

  override var isSelected: Bool {
    didSet {
      setupBackgroundColor()
    }
  }

  override public var isEnabled: Bool {
    didSet {
      setupBackgroundColor()
      titleColor(for: state).map { imageView?.tintColor = $0 }
    }
  }
  
  init(style: Style? = nil, frame: CGRect = .zero) {
    self.style = style
    super.init(frame: frame)
    setup()
    setupStyle()
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
  
  func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
    backgroundColorsByState[state.rawValue] = color
    setupBackgroundColor()
  }
  
  func backgroundColor(for state: UIControl.State) -> UIColor? {
    return backgroundColorsByState[state.rawValue]
  }
  
}

// MARK: - Private Methods

private extension Button {
  
  func setup() {
    clipsToBounds = true
    isExclusiveTouch = true
    adjustsImageWhenDisabled = false
    adjustsImageWhenHighlighted = false
  }
  
  func setupBackgroundColor() {
    super.backgroundColor = backgroundColor(for: state) ?? backgroundColor(for: .normal)
  }
  
  func setupStyle() {
    guard let style = style else { return }
    switch style {
    case .titleAndImageCenter:
      semanticContentAttribute = .forceRightToLeft
      imageEdgeInsets.right = -8
    case .imageAndTitleCenter:
      imageEdgeInsets.left = -8
    }
  }
  
}
