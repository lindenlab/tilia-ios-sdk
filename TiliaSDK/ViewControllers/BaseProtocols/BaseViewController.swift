//
//  BaseViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.04.2022.
//

import UIKit

class BaseViewController: UIViewController {
  
  var hideableView: UIView {
    return view
  }
  
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
  
  private var spinner: UIActivityIndicatorView?
  private var button: NonPrimaryButton?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  final func startLoading() {
    guard spinner == nil else { return }
    let spinner = UIActivityIndicatorView(style: .large)
    self.spinner = spinner
    spinner.startAnimating()
    spinner.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(spinner)
    NSLayoutConstraint.activate([
      spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    hideableView.isHidden = true
  }
  
  final func stopLoading() {
    guard spinner != nil else { return }
    spinner?.removeFromSuperview()
    spinner = nil
    hideableView.isHidden = false
  }
  
  final func showCloseButton(target: Any, action: Selector) {
    guard button == nil else { return }
    let button = NonPrimaryButton()
    button.setTitle(L.close, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.accessibilityIdentifier = "closeButton"
    button.addTarget(target, action: action, for: .touchUpInside)
    view.addSubview(button)
    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      button.widthAnchor.constraint(equalToConstant: 100)
    ])
    self.button = button
  }
  
  final func removeCloseButton() {
    guard button != nil else { return }
    button?.removeFromSuperview()
    button = nil
  }
  
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension BaseViewController: UIAdaptivePresentationControllerDelegate {
  
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) { }
  
}

// MARK: - Private Methods

private extension BaseViewController {
  
  func setup() {
    presentationController?.delegate = self
    
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
