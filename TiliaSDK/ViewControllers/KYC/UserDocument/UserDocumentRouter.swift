//
//  UserDocumentRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 17.05.2022.
//

import UIKit

protocol UserDocumentRoutingProtocol: RoutingProtocol { }

final class UserDocumentRouter: UserDocumentRoutingProtocol {
  
  weak var viewController: UIViewController?
  
}
