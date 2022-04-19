//
//  RoutingProtocol.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 28.03.2022.
//

import UIKit
import SafariServices

protocol RoutingProtocol {
  var viewController: UIViewController? { get }
  
  func dismiss(animated: Bool, completion: (() -> Void)?)
}

// MARK: - Default Implementation

extension RoutingProtocol {
  
  func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
    viewController?.dismiss(animated: animated, completion: completion)
  }
  
  func showToast(title: String, message: String) {
    if let transitionCoordinator = viewController?.transitionCoordinator {
      transitionCoordinator.animate(alongsideTransition: nil) { _ in
        self.viewController?.view.showToast(title: title, message: message)
      }
    } else {
      viewController?.view.showToast(title: title, message: message)
    }
  }
  
  func showWebView(with link: String) {
    guard let model = TosAcceptModel(str: link) else { return }
    let safariViewController = SFSafariViewController(url: model.url)
    viewController?.present(safariViewController, animated: true)
  }
  
}

// MARK: - Private Methods

private extension UIView {
  
  func showToast(title: String, message: String) {
    let toast = ToastView(isSuccess: false)
    toast.configure(title: title, message: message)
    toast.translatesAutoresizingMaskIntoConstraints = false
    addSubview(toast)
    
    let hidden = toast.topAnchor.constraint(equalTo: bottomAnchor)
    let visible = [
      toast.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(safeAreaInsets.bottom + 20))
    ]

    NSLayoutConstraint.activate([
      hidden,
      toast.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 16),
      toast.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -16)
    ])

    layoutIfNeeded()

    hidden.isActive = false
    NSLayoutConstraint.activate(visible)
    
    UIView.animate(withDuration: 0.3,
                   animations: { self.layoutIfNeeded() },
                   completion: { _ in
      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
        NSLayoutConstraint.deactivate(visible)
        hidden.isActive = true
        UIView.animate(withDuration: 0.3,
                       animations: { self.layoutIfNeeded() },
                       completion: { _ in toast.removeFromSuperview()})
      }
    })
  }
  
}
