//
//  CheckoutRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

protocol CheckoutRoutingProtocol: PaymentMethodActionsRoutingProtocol {
  func routeToTosView()
  func routeToTosContentView()
  func routeToAddPaymentMethodView(with mode: AddPaymentMethodMode)
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
                                              onError: dataStore.onError)
    if let transitionCoordinator = viewController?.transitionCoordinator {
      transitionCoordinator.animate(alongsideTransition: nil) { _ in
        self.viewController?.present(tosViewController, animated: true)
      }
    } else {
      viewController?.present(tosViewController, animated: true)
    }
  }
  
  func routeToTosContentView() {
    let tosContentViewController = TosContentViewController(manager: dataStore.manager,
                                                            onError: dataStore.onError)
    viewController?.present(tosContentViewController, animated: true)
  }
  
  func routeToAddPaymentMethodView(with mode: AddPaymentMethodMode) {
    let addCreditCardViewController = AddPaymentMethodViewController(manager: dataStore.manager,
                                                                     mode: mode,
                                                                     onReload: dataStore.onReload,
                                                                     onError: dataStore.onError)
    viewController?.present(addCreditCardViewController, animated: true)
  }
  
}
