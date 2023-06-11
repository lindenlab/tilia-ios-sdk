//
//  AuthRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 24.06.2022.
//

import Alamofire

enum AuthRouter: RouterProtocol {
  
  case getAddCreditCardRedirectUrl
  case getPaypalRedirectUrl
  
  var method: HTTPMethod {
    switch self {
    case .getAddCreditCardRedirectUrl, .getPaypalRedirectUrl: return .post
    }
  }
  
  var bodyParameters: Parameters? {
    var parameters = ["mechanism": "tilia_hosted"]
    switch self {
    case .getAddCreditCardRedirectUrl:
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
    case .getAddCreditCardRedirectUrl, .getPaypalRedirectUrl:
      return readJSONFromFile("GetAddPaymentMethodRedirectUrlResponse")
    }
  }
  
}
