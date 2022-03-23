//
//  InvoiceRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

enum InvoiceRouter: RouterProtocol {
  
  var method: HTTPMethod { return .get }
  
  var service: String { return "invoicing" }
  
  var endpoint: String { return "" }
  
}
