//
//  UserInfoRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import UIKit

protocol UserInfoRoutingProtocol: RoutingProtocol {
  func routeToUserDocumentsView()
  func routeToVerifyEmailView()
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
                                                                  onComplete: dataStore.onUserDocumentsComplete,
                                                                  onError: dataStore.onError)
    viewController?.present(userDocumentsViewController, animated: true)
  }
  
  func routeToVerifyEmailView() {
    let verifyEmailViewController = VerifyEmailViewController(email: dataStore.userEmail,
                                                              flow: .kyc,
                                                              mode: dataStore.verifyEmailMode,
                                                              manager: dataStore.manager,
                                                              onEmailVerified: dataStore.onEmailVerified,
                                                              onUpdate: dataStore.onUpdate,
                                                              onError: dataStore.onError)
    viewController?.present(verifyEmailViewController, animated: true)
  }
  
}
