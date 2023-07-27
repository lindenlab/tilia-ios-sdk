//
//  AuthRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 24.06.2022.
//

import Alamofire

enum AuthRouter: RouterProtocol {
  
  case getCreditCardRedirectUrl
  case getPaypalRedirectUrl
  
  var method: HTTPMethod {
    switch self {
    case .getCreditCardRedirectUrl, .getPaypalRedirectUrl: return .post
    }
  }
  
  var bodyParameters: Parameters? {
    var parameters = ["mechanism": "tilia_hosted"]
    switch self {
    case .getCreditCardRedirectUrl:
      parameters["flow"] = "addcard"
    case .getPaypalRedirectUrl:
      parameters["flow"] = "addpaypal"
    }
    return parameters
  }
  
  var service: String { return "auth" }
  
  var endpoint: String { return "/authorize/user" }
  
}

// MARK: - For Unit Tests

extension AuthRouter {
  
  var testData: Data? {
    switch self {
    case .getCreditCardRedirectUrl, .getPaypalRedirectUrl:
      return readJSONFromFile("GetAddPaymentMethodRedirectUrlResponse")
    }
  }
  
}
