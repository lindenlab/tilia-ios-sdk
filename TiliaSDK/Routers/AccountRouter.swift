//
//  AccountRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

enum AccountRouter: RouterProtocol {
  
  case getTosRequiredForUser
  
  var method: HTTPMethod {
    switch self {
    case .getTosRequiredForUser: return .get
    }
  }
  
  var service: String { return "accounts" }
  
  var endpoint: String {
    switch self {
    case .getTosRequiredForUser: return "/v1/user-info/tos/tilia"
    }
  }
  
}
