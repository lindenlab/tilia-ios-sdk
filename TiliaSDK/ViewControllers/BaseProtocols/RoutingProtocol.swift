//
//  RoutingProtocol.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 28.03.2022.
//

import UIKit

protocol RoutingProtocol {
  var viewController: UIViewController? { get }
  
  func dismiss(animated: Bool, completion: (() -> Void)?)
  func showAlert(title: String, message: String?, cancelAction: (() -> Void)?, otherActions: [UIAlertAction])
}

// MARK: - Default Implementation

extension RoutingProtocol {
  
  func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
    viewController?.dismiss(animated: animated, completion: completion)
  }
  
  func showAlert(title: String, message: String? = nil, cancelAction: (() -> Void)? = nil, otherActions: [UIAlertAction] = []) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: L.ok, style: .cancel) { _ in cancelAction?() }
    alertController.addAction(okAction)
    otherActions.forEach { alertController.addAction($0) }
    viewController?.present(alertController, animated: true)
  }
  
}
