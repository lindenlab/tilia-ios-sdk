//
//  PaymentSelectionRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.05.2023.
//

import UIKit

protocol PaymentSelectionRoutingProtocol: RoutingProtocol {
  func routeToTosView()
  func routeToTosContentView()
  func routeToAddCreditCardView()
}

final class PaymentSelectionRouter: PaymentSelectionRoutingProtocol {
  
  weak var viewController: UIViewController?
  private let dataStore: PaymentSelectionDataStore
  
  init(dataStore: PaymentSelectionDataStore) {
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
  
  func routeToAddCreditCardView() {
    let addCreditCardViewController = AddCreditCardViewController(manager: dataStore.manager,
                                                                  onReload: dataStore.onReload,
                                                                  onError: dataStore.onError)
    viewController?.present(addCreditCardViewController, animated: true)
  }
  
}
