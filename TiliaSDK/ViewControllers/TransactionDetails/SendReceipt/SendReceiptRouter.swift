//
//  SendReceiptRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import UIKit

protocol SendReceiptRoutingProtocol: RoutingProtocol {
  func routeToVerifyEmailView()
}

final class SendReceiptRouter: SendReceiptRoutingProtocol {
  
  weak var viewController: UIViewController?
  private let dataStore: SendReceiptDataStore
  
  init(dataStore: SendReceiptDataStore) {
    self.dataStore = dataStore
  }
  
  func routeToVerifyEmailView() {
    let verifyEmailViewController = VerifyEmailViewController(email: dataStore.userEmail,
                                                              flow: .transactionDetails,
                                                              mode: dataStore.verifyEmailMode,
                                                              manager: dataStore.manager,
                                                              onEmailVerified: dataStore.onEmailVerified,
                                                              onUpdate: dataStore.onUpdate,
                                                              onError: dataStore.onError)
    viewController?.present(verifyEmailViewController, animated: true)
  }
  
}
