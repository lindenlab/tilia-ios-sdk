//
//  RadioButton.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 01.04.2022.
//

import UIKit

final class RadioButton: Button {
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: 20, height: 20)
  }
  
  var isRadioSelected: Bool = false {
    didSet {
      setupBorder()
    }
  }
  
  override init(style: Style? = nil, frame: CGRect = .zero) {
    super.init(style: style, frame: frame)
    addTarget(self, action: #selector(didTap), for: .touchUpInside)
    setBackgroundColor(.backgroundColor, for: .normal)
    setBackgroundColor(.backgroundDarkerColor, for: .disabled)
    setupBorder()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = bounds.height * 0.5
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
    setupBorder()
  }
  
}

// MARK: - Private Methods

private extension RadioButton {
  
  func setupBorder() {
    if isRadioSelected {
      layer.borderWidth = 6
      layer.borderColor = UIColor.primaryColor.cgColor
    } else {
      layer.borderWidth = 2
      layer.borderColor = UIColor.borderColor.cgColor
    }
  }
  
  @objc func didTap() {
    guard !isRadioSelected else { return }
    isRadioSelected.toggle()
  }
  
}
