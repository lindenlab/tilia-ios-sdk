//
//  UserDocumentsRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 17.05.2022.
//

import UIKit

protocol UserDocumentsRoutingProtocol: RoutingProtocol { }

final class UserDocumentsRouter: UserDocumentsRoutingProtocol {
  
  weak var viewController: UIViewController?
  
}
