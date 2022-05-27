//
//  AccountRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

enum AccountRouter: RouterProtocol {
  
  case getTosRequiredForUser
  case signTosForUser
  
  var method: HTTPMethod {
    switch self {
    case .getTosRequiredForUser: return .get
    case .signTosForUser: return .post
    }
  }
  
  var service: String { return "accounts" }
  
  var endpoint: String { return "/v1/user-info/tos/tilia" }
  
}

// MARK: - For Unit Tests

extension AccountRouter {
  
  var testData: Data? {
    switch self {
    case .getTosRequiredForUser: return readJSONFromFile("GetTosRequiredForUserResponse")
    case .signTosForUser: return readJSONFromFile("SignTosForUserResponse")
    }
  }
  
}
