//
//  DeletePaymentMethodViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 25.05.2023.
//

import UIKit
import Combine

final class DeletePaymentMethodViewController: UIAlertController {
  
  private var viewModel: DeletePaymentMethodViewModelProtocol!
  private var subscriptions: Set<AnyCancellable> = []

  convenience init(manager: NetworkManager,
                   paymentMethodId: String,
                   onDelete: @escaping () -> Void,
                   onUpdate: ((TLUpdateCallback) -> Void)?,
                   onError: ((TLErrorCallback) -> Void)?) {
    self.init(title: L.removePaymentMethodTitle,
              message: L.removePaymentMethodMessage,
              preferredStyle: .alert)
    viewModel = DeletePaymentMethodViewModel(manager: manager,
                                             paymentMethodId: paymentMethodId,
                                             onDelete: onDelete,
                                             onUpdate: onUpdate,
                                             onError: onError)
    setupActions()
  }
  
}

// MARK: - Private Methods

private extension DeletePaymentMethodViewController {
  
  func setupActions() {
    let cancelAction = UIAlertAction(title: L.cancel, style: .cancel)
    let removeAction = UIAlertAction(title: L.remove, style: .destructive) { [weak self] _ in
      
    }
    addAction(cancelAction)
    addAction(removeAction)
  }
  
}
