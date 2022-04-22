//
//  CheckoutRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

protocol CheckoutRoutingProtocol: RoutingProtocol {
  func routeToTosView()
  func routeToAddCreditCard()
}

final class CheckoutRouter: CheckoutRoutingProtocol {
  
  weak var viewController: UIViewController?
  private let dataStore: CheckoutDataStore
  
  init(dataStore: CheckoutDataStore) {
    self.dataStore = dataStore
  }
  
  func routeToTosView() {
    let tosViewController = TosViewController(manager: dataStore.manager,
                                              onComplete: dataStore.onTosComplete,
                                              onError: dataStore.onTosError)
    if let transitionCoordinator = viewController?.transitionCoordinator {
      transitionCoordinator.animate(alongsideTransition: nil) { _ in
        self.viewController?.present(tosViewController, animated: true)
      }
    } else {
      viewController?.present(tosViewController, animated: true)
    }
  }
  
  func routeToAddCreditCard() {
    let addCreditCardViewController = AddCreditCardViewController(manager: dataStore.manager)
    viewController?.present(addCreditCardViewController, animated: true)
  }
  
}
