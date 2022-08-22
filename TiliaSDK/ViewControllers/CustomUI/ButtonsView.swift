//
//  ButtonsView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import UIKit

protocol ButtonsViewDelegate: AnyObject {
  func buttonsViewPrimaryButtonDidTap()
  func buttonsViewPrimaryNonButtonDidTap()
}

final class ButtonsView<Primary: PrimaryButton, NonPrimary: NonPrimaryButton>: UIView {
  
  weak var delegate: ButtonsViewDelegate?
  
  let primaryButton: Primary
  let nonPrimaryButton: NonPrimary
  
  init(frame: CGRect = .zero,
       primaryButton: Primary,
       nonPrimaryButton: NonPrimary,
       insets: UIEdgeInsets = .zero) {
    self.primaryButton = primaryButton
    self.nonPrimaryButton = nonPrimaryButton
    super.init(frame: frame)
    setup(insets: insets)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc private func primaryButtonDidTap() {
    delegate?.buttonsViewPrimaryButtonDidTap()
  }
  
  @objc private func nonPrimaryButtonDidTap() {
    delegate?.buttonsViewPrimaryNonButtonDidTap()
  }
  
}

// MARK: - Private Methods

private extension ButtonsView {
  
  func setup(insets: UIEdgeInsets) {
    backgroundColor = .backgroundColor
    
    primaryButton.addTarget(self, action: #selector(primaryButtonDidTap), for: .touchUpInside)
    nonPrimaryButton.addTarget(self, action: #selector(nonPrimaryButtonDidTap), for: .touchUpInside)
    
    let stackView = UIStackView(arrangedSubviews: [primaryButton, nonPrimaryButton])
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
      stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: insets.left),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
      stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -insets.right)
    ])
  }
  
}
