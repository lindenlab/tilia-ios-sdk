//
//  CheckoutRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

protocol CheckoutRoutingProtocol: RoutingProtocol {
  func routeToTosView(completion: @escaping (Bool) -> Void)
}

final class CheckoutRouter: CheckoutRoutingProtocol {
  
  weak var viewController: UIViewController?
  
  func routeToTosView(completion: @escaping (Bool) -> Void) {
    let tosViewController = TosViewController(completion: completion)
    viewController?.present(tosViewController, animated: true)
  }
  
}
