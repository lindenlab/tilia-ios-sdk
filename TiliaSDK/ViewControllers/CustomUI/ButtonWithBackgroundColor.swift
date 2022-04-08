//
//  ButtonWithBackgroundColor.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 05.04.2022.
//

import UIKit

class ButtonWithBackgroundColor: UIButton {
  
  private var backgroundColorsByState: [UInt: UIColor] = [:]
  
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
    }
  }
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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

private extension ButtonWithBackgroundColor {
  
  func setup() {
    clipsToBounds = true
    isExclusiveTouch = true
  }
  
  func setupBackgroundColor() {
    super.backgroundColor = backgroundColor(for: state) ?? backgroundColor(for: .normal)
  }
  
}
