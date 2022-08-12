//
//  TosContentRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 12.08.2022.
//

import UIKit

protocol TosContentRoutingProtocol: RoutingProtocol { }

final class TosContentRouter: TosContentRoutingProtocol {
  
  weak var viewController: UIViewController?
  
}
