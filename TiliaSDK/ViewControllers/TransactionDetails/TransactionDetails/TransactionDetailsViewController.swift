//
//  TransactionDetailsViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import UIKit

final class TransactionDetailsViewController: BaseViewController {
  
  private let viewModel: TransactionDetailsViewModelProtocol
  private let router: TransactionDetailsRoutingProtocol
  
  init(manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    let viewModel = TransactionDetailsViewModel(manager: manager,
                                                onUpdate: onUpdate,
                                                onComplete: onComplete,
                                                onError: onError)
    let router = TransactionDetailsRouter(dataStore: viewModel)
    self.viewModel = viewModel
    self.router = router
    super.init(nibName: nil, bundle: nil)
    router.viewController = self
    self.presentationController?.delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
