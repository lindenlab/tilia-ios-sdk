//
//  TransactionDetailsRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import UIKit

protocol TransactionDetailsRoutingProtocol: RoutingProtocol {
  func routeToTosView()
  func routeToSendReceiptView()
}

final class TransactionDetailsRouter: TransactionDetailsRoutingProtocol {
  
  weak var viewController: UIViewController?
  private let dataStore: TransactionDetailsDataStore
  
  init(dataStore: TransactionDetailsDataStore) {
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
  
  func routeToSendReceiptView() {
    let sendReceiptViewController = SendReceiptViewController(transactionId: dataStore.transactionId,
                                                              manager: dataStore.manager,
                                                              onUpdate: dataStore.onUpdate,
                                                              onError: dataStore.onError)
    viewController?.present(sendReceiptViewController, animated: true)
  }
  
}
