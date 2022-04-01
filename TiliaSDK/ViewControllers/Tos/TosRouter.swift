//
//  TosRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 28.03.2022.
//

import UIKit

protocol TosRoutingProtocol: RoutingProtocol { }

final class TosRouter: TosRoutingProtocol {
  
  weak var viewController: UIViewController?
  
}
