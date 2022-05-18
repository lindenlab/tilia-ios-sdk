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
  
  func routeToUserDocumentsView() {
    
  }
  
}
