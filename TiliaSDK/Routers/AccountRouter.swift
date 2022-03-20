//
//  AccountRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

enum AccountRouter: RouterProtocol {
  
  var method: HTTPMethod { return .get }
  
  var bodyParameters: Parameters? { return nil }
  
  var service: String { return "accounts" }
  
  var endpoint: String { return "" }
  
}
