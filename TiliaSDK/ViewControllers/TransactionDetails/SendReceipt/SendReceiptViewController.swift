//
//  SendReceiptViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import UIKit

final class SendReceiptViewController: BaseViewController {
  
  private let viewModel: SendReceiptViewModelProtocol
  private let router: SendReceiptRoutingProtocol
  
  init(manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    let viewModel = SendReceiptViewModel(manager: manager,
                                         onUpdate: onUpdate,
                                         onError: onError)
    let router = SendReceiptRouter()
    self.viewModel = viewModel
    self.router = router
    super.init()
    router.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
