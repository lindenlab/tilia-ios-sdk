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
    guard let model = TosAcceptModel(str: link) else { return }
    let safariViewController = SFSafariViewController(url: model.url)
    viewController?.present(safariViewController, animated: true)
  }
  
}
