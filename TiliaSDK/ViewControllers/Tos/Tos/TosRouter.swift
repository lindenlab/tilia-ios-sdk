//
//  TosRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 28.03.2022.
//

import UIKit

protocol TosRoutingProtocol: RoutingProtocol {
  func routeToTosContentView()
}

final class TosRouter: TosRoutingProtocol {
  
  weak var viewController: UIViewController?
  private let dataStore: TosDataStore
  
  init(dataStore: TosDataStore) {
    self.dataStore = dataStore
  }
  
  func routeToTosContentView() {
    let tosContentViewController = TosContentViewController(manager: dataStore.manager,
                                                            onError: dataStore.onTosContentError)
    viewController?.present(tosContentViewController, animated: true)
  }
  
}
