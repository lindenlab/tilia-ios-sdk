//
//  BaseViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.04.2022.
//

import UIKit

class BaseViewController: UIViewController {
  
  let logoImageView: UIImageView = {
    let imageView = UIImageView(image: .logoIcon)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  let divider: DividerView = {
    let divider = DividerView()
    divider.translatesAutoresizingMaskIntoConstraints = false
    return divider
  }()
  
  lazy var closeButton: NonPrimaryButton = {
    let button = NonPrimaryButton()
    button.setTitle(L.close, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.accessibilityIdentifier = "closeButton"
    
    view.addSubview(button)
    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      button.widthAnchor.constraint(equalToConstant: 100)
    ])
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
}

// MARK: - Private Methods

private extension BaseViewController {
  
  func setup() {
    view.backgroundColor = .backgroundColor
    view.addSubview(logoImageView)
    view.addSubview(divider)
    
    NSLayoutConstraint.activate([
      divider.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
      divider.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
      divider.bottomAnchor.constraint(equalTo: logoImageView.topAnchor, constant: -16),
      logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      logoImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
    ])
  }
  
}
