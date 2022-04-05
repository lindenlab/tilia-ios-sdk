//
//  ButtonWithBackgroundColor.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 05.04.2022.
//

import UIKit

class ButtonWithBackgroundColor: UIButton {
  
  private var backgroundColorsByState: [UInt: UIColor] = [:]
  
  private let highlightedBackgroundView: UIView = {
    let view = UIView()
    view.isUserInteractionEnabled = false
    view.alpha = 0
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
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

  override public func layoutSubviews() {
    super.layoutSubviews()
    sendSubviewToBack(highlightedBackgroundView)
  }
  
  func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
    backgroundColorsByState[state.rawValue] = color
    setupBackgroundColor()
  }
  
  func backgroundColor(for state: UIControl.State) -> UIColor? {
    backgroundColorsByState[state.rawValue]
  }
  
}

// MARK: - Private Methods

private extension ButtonWithBackgroundColor {
  
  func setup() {
    clipsToBounds = true
    isExclusiveTouch = true
    addSubview(highlightedBackgroundView)

    NSLayoutConstraint.activate([
      highlightedBackgroundView.topAnchor.constraint(equalTo: topAnchor),
      highlightedBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
      highlightedBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
      highlightedBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
  
  func setupBackgroundColor() {
    super.backgroundColor = backgroundColor(for: state) ?? backgroundColor(for: .normal)
    if isHighlighted && highlightedBackgroundView.alpha == 0 {
      highlightedBackgroundView.backgroundColor = {
        if isSelected, let color = backgroundColor(for: .init([.selected, .highlighted])) {
          return color
        } else {
          return backgroundColor(for: .highlighted)
        }
      }()
    } else if !isHighlighted && highlightedBackgroundView.alpha == 1 {
      UIView.animate(withDuration: 0.25) {
        self.highlightedBackgroundView.alpha = 0
      }
    } else {
      highlightedBackgroundView.alpha = isHighlighted ? 1 : 0
    }
  }
  
}
