//
//  ButtonsView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import UIKit

protocol ButtonsViewDelegate: AnyObject {
  func buttonsViewPrimaryButtonDidTap(_ view: ButtonsView)
  func buttonsViewPrimaryNonButtonDidTap(_ view: ButtonsView)
}

final class ButtonsView: UIView {
  
  weak var delegate: ButtonsViewDelegate?
  
  let primaryButton: PrimaryButton
  let nonPrimaryButton: NonPrimaryButton
  
  init(frame: CGRect = .zero,
       primaryButton: PrimaryButton,
       nonPrimaryButton: NonPrimaryButton,
       insets: UIEdgeInsets = .zero) {
    self.primaryButton = primaryButton
    self.nonPrimaryButton = nonPrimaryButton
    super.init(frame: frame)
    setup(insets: insets)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Private Methods

private extension ButtonsView {
  
  func setup(insets: UIEdgeInsets) {
    backgroundColor = .clear
    
    primaryButton.addTarget(self, action: #selector(primaryButtonDidTap), for: .touchUpInside)
    nonPrimaryButton.addTarget(self, action: #selector(nonPrimaryButtonDidTap), for: .touchUpInside)
    
    let stackView = UIStackView(arrangedSubviews: [primaryButton, nonPrimaryButton])
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stackView)
    
    let topConstraint = stackView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top)
    topConstraint.priority = UILayoutPriority(999)
    
    let leftConstraint = stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: insets.left)
    leftConstraint.priority = UILayoutPriority(999)
    
    NSLayoutConstraint.activate([
      topConstraint,
      leftConstraint,
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
      stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -insets.right)
    ])
  }
  
  @objc func primaryButtonDidTap() {
    delegate?.buttonsViewPrimaryButtonDidTap(self)
  }
  
  @objc func nonPrimaryButtonDidTap() {
    delegate?.buttonsViewPrimaryNonButtonDidTap(self)
  }
  
}
