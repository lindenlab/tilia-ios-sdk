//
//  TransactionDetailsRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import UIKit

protocol TransactionDetailsRoutingProtocol: RoutingProtocol {
  func routeToSendReceiptView()
}

final class TransactionDetailsRouter: TransactionDetailsRoutingProtocol {
  
  weak var viewController: UIViewController?
  private let dataStore: TransactionDetailsDataStore
  
  init(dataStore: TransactionDetailsDataStore) {
    self.dataStore = dataStore
  }
  
  func routeToSendReceiptView() {
    
  }
  
}
