//
//  TosRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 28.03.2022.
//

import UIKit
import SafariServices

protocol TosRoutingProtocol: RoutingProtocol {
  func routeToWebView(with link: String)
}

final class TosRouter: TosRoutingProtocol {
  
  weak var viewController: UIViewController?
  
  func routeToWebView(with link: String) {
    guard let model = TosAcceptModel(rawValue: link) else { return }
    let safariViewController = SFSafariViewController(url: model.url)
    viewController?.present(safariViewController, animated: true)
  }
  
  func dismiss(animated: Bool, completion: (() -> Void)?) {
    if let presentedViewController = viewController?.presentedViewController {
      presentedViewController.dismiss(animated: animated) {
        self.viewController?.dismiss(animated: animated)
      }
    } else {
      viewController?.dismiss(animated: animated)
    }
  }
  
}
