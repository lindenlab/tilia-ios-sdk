//
//  TransactionHistoryRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.09.2022.
//

import UIKit

protocol TransactionHistoryRoutingProtocol: RoutingProtocol {
  func routeToTosView()
  func routeToTransactionDetailsView()
}

final class TransactionHistoryRouter: TransactionHistoryRoutingProtocol {
  
  weak var viewController: UIViewController?
  private let dataStore: TransactionHistoryDataStore
  
  init(dataStore: TransactionHistoryDataStore) {
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
  
  func routeToTransactionDetailsView() {
    guard let selectedTransaction = dataStore.selectedTransaction else { return }
    let transactionDetailsController = TransactionDetailsViewController(mode: .transaction(selectedTransaction),
                                                                        manager: dataStore.manager,
                                                                        onUpdate: dataStore.onUpdate,
                                                                        onComplete: dataStore.onComplete,
                                                                        onError: dataStore.onError)
    viewController?.present(transactionDetailsController, animated: true)
  }
  
}
