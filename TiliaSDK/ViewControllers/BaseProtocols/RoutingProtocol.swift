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
  func showAlert(title: String, message: String?, otherActions: [UIAlertAction], cancelTitle: String, cancelAction: (() -> Void)?)
  func showWebView(with link: String)
}

// MARK: - Default Implementation

extension RoutingProtocol {
  
  func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
    viewController?.dismiss(animated: animated, completion: completion)
  }
  
  func showAlert(title: String,
                 message: String? = nil,
                 otherActions: [UIAlertAction] = [],
                 cancelTitle: String = L.ok,
                 cancelAction: (() -> Void)? = nil) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in cancelAction?() }
    alertController.addAction(okAction)
    otherActions.forEach { alertController.addAction($0) }
    viewController?.present(alertController, animated: true)
  }
  
  func showWebView(with link: String) {
    guard let model = TosAcceptModel(str: link) else { return }
    let safariViewController = SFSafariViewController(url: model.url)
    viewController?.present(safariViewController, animated: true)
  }
  
}
