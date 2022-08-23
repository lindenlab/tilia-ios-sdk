//
//  UserInfoRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import UIKit

protocol UserInfoRoutingProtocol: RoutingProtocol {
  func routeToUserDocumentsView()
}

final class UserInfoRouter: UserInfoRoutingProtocol {
  
  weak var viewController: UIViewController?
  private let dataStore: UserInfoDataStore
  
  init(dataStore: UserInfoDataStore) {
    self.dataStore = dataStore
  }
  
  func routeToUserDocumentsView() {
    let userDocumentsViewController = UserDocumentsViewController(manager: dataStore.manager,
                                                                  userInfoModel: dataStore.userInfoModel,
                                                                  onUpdate: dataStore.onUpdate,
                                                                  onComplete: dataStore.onUserDocumentsComplete,
                                                                  onError: dataStore.onError)
    viewController?.present(userDocumentsViewController, animated: true)
  }
  
}
