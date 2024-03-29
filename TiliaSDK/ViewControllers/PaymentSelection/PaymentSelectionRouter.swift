//
//  PaymentSelectionRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.05.2023.
//

import UIKit

protocol PaymentMethodActionsRoutingProtocol: RoutingProtocol { }

extension PaymentMethodActionsRoutingProtocol {
  
  func routeToDeletePaymentMethodView(removeAction: @escaping () -> Void) {
    let alertController = UIAlertController(title: L.removePaymentMethodTitle,
                                            message: L.removePaymentMethodMessage,
                                            preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: L.cancel, style: .cancel)
    let removeAction = UIAlertAction(title: L.remove, style: .destructive) { _ in
      removeAction()
    }
    alertController.addAction(cancelAction)
    alertController.addAction(removeAction)
    viewController?.present(alertController, animated: true)
  }
  
  func routeToRenamePaymentMethodView(with name: String, textFieldDelegate: LimitTextFieldDelegate, renameAction: @escaping (String) -> Void) {
    let alertController = UIAlertController(title: L.renamePaymentMethodTitle,
                                            message: L.renamePaymentMethodMessage,
                                            preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: L.cancel, style: .cancel)
    let renameAction = UIAlertAction(title: L.rename, style: .default) { [weak alertController] _ in
      renameAction(alertController?.textFields?.first?.text ?? "")
    }
    textFieldDelegate.textWillChangeAction = {
      renameAction.isEnabled = !$0.isEmpty
    }
    alertController.addTextField {
      $0.placeholder = L.newName
      $0.text = name
      $0.delegate = textFieldDelegate
    }
    alertController.addAction(cancelAction)
    alertController.addAction(renameAction)
    viewController?.present(alertController, animated: true)
  }
  
}

protocol PaymentSelectionRoutingProtocol: PaymentMethodActionsRoutingProtocol {
  func routeToTosView()
  func routeToTosContentView()
  func routeToAddPaymentMethodView(with mode: AddPaymentMethodMode)
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
  
  func routeToAddPaymentMethodView(with mode: AddPaymentMethodMode) {
    let addCreditCardViewController = AddPaymentMethodViewController(manager: dataStore.manager,
                                                                     mode: mode,
                                                                     onReload: dataStore.onReload,
                                                                     onError: dataStore.onError)
    viewController?.present(addCreditCardViewController, animated: true)
  }
  
}
