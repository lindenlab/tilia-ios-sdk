//
//  RadioButton.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 01.04.2022.
//

import UIKit

final class RadioButton: UIButton {
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: 20, height: 20)
  }
  
  private(set) var isRadioSelected: Bool = false {
    didSet {
      setup()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    addTarget(self, action: #selector(didTap), for: .touchUpInside)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = bounds.height * 0.5
    setup()
  }
  
  func setSelected(_ isSelected: Bool) {
    isRadioSelected = isSelected
  }
  
}

// MARK: - Private Methods

private extension RadioButton {
  
  func setup() {
    if isRadioSelected {
      layer.borderWidth = 6
      layer.borderColor = UIColor.radioButtonColor.cgColor
    } else {
      layer.borderWidth = 2
      layer.borderColor = UIColor.dividerColor.cgColor
    }
  }
  
  @objc func didTap() {
    isRadioSelected.toggle()
  }
  
}
