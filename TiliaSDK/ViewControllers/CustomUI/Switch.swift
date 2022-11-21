//
//  Switch.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.11.2022.
//

import UIKit

final class Switch: UISwitch {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Private Methods

private extension Switch {
  
  func setup() {
    clipsToBounds = true
    layer.cornerRadius = frame.height / 2
    backgroundColor = .borderColor
    onTintColor = .primaryColor
    setContentHuggingPriority(.required, for: .horizontal)
    setContentCompressionResistancePriority(.required, for: .horizontal)
  }
  
}
