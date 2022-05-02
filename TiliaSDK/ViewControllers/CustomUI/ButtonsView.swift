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
  
  var primaryButtonText: String? {
    get {
      return primaryButton.title(for: .normal)
    }
    set {
      primaryButton.setTitle(newValue, for: .normal)
    }
  }
  
  var isPrimaryButtonEnabled: Bool {
    get {
      return primaryButton.isEnabled
    }
    set {
      primaryButton.isEnabled = newValue
    }
  }
  
  var primaryButtonAccessibilityIdentifier: String? {
    get {
      return primaryButton.accessibilityIdentifier
    }
    set {
      primaryButton.accessibilityIdentifier = newValue
    }
  }
  
  var nonPrimaryButtonText: String? {
    get {
      return nonPrimaryButton.title(for: .normal)
    }
    set {
      nonPrimaryButton.setTitle(newValue, for: .normal)
    }
  }
  
  var nonPrimaryButtonAccessibilityIdentifier: String? {
    get {
      return nonPrimaryButton.accessibilityIdentifier
    }
    set {
      nonPrimaryButton.accessibilityIdentifier = newValue
    }
  }
  
  private lazy var primaryButton: PrimaryButton = {
    let button = PrimaryButton()
    button.addTarget(self, action: #selector(primaryButtonDidTap), for: .touchUpInside)
    return button
  }()
  
  private lazy var nonPrimaryButton: NonPrimaryButton = {
    let button = NonPrimaryButton()
    button.addTarget(self, action: #selector(nonPrimaryButtonDidTap), for: .touchUpInside)
    return button
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Private Methods

private extension ButtonsView {
  
  func setup() {
    backgroundColor = .clear
    let stackView = UIStackView(arrangedSubviews: [primaryButton, nonPrimaryButton])
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
      stackView.leftAnchor.constraint(equalTo: leftAnchor),
      stackView.rightAnchor.constraint(equalTo: rightAnchor)
    ])
  }
  
  @objc func primaryButtonDidTap() {
    delegate?.buttonsViewPrimaryButtonDidTap(self)
  }
  
  @objc func nonPrimaryButtonDidTap() {
    delegate?.buttonsViewPrimaryNonButtonDidTap(self)
  }
  
}
