//
//  TransactionDetailsViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import UIKit

final class TransactionDetailsViewController: BaseTableViewController {
  
  private let viewModel: TransactionDetailsViewModelProtocol
  private let router: TransactionDetailsRoutingProtocol
  
  init(invoiceId: String,
       manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    let viewModel = TransactionDetailsViewModel(invoiceId: invoiceId,
                                                manager: manager,
                                                onUpdate: onUpdate,
                                                onComplete: onComplete,
                                                onError: onError)
    let router = TransactionDetailsRouter(dataStore: viewModel)
    self.viewModel = viewModel
    self.router = router
    super.init()
    router.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
