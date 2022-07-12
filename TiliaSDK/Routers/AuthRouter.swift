//
//  AuthRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 24.06.2022.
//

import Alamofire

enum AuthRouter: RouterProtocol {
  
  case getAddCreditCardRedirectUrl
  
  var method: HTTPMethod {
    switch self {
    case .getAddCreditCardRedirectUrl: return .post
    }
  }
  
  var bodyParameters: Parameters? {
    switch self {
    case .getAddCreditCardRedirectUrl: return [
      "mechanism": "tilia_hosted",
      "flow": "addcard"
    ]
    }
  }
  
  var service: String { return "auth" }
  
  var endpoint: String { return "/authorize/user" }
  
}

// MARK: - For Unit Tests

extension AuthRouter {
  
  var testData: Data? {
    switch self {
    case .getAddCreditCardRedirectUrl: return readJSONFromFile("GetAddCreditCardRedirectUrlResponse")
    }
  }
  
}
