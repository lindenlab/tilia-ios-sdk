//
//  VerifyEmailRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.05.2023.
//

import UIKit

protocol VerifyEmailRoutingProtocol: RoutingProtocol { }

final class VerifyEmailRouter: VerifyEmailRoutingProtocol {
  
  weak var viewController: UIViewController?
  
}
