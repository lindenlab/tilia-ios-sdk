//
//  SendReceiptRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import UIKit

protocol SendReceiptRoutingProtocol: RoutingProtocol { }

final class SendReceiptRouter: SendReceiptRoutingProtocol {
  
  weak var viewController: UIViewController?
  
}
