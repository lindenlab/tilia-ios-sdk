//
//  PaymentRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

enum PaymentRouter: RouterProtocol {
  
  case getUserBalanceByCurrencyCode
  
  var method: HTTPMethod {
    switch self {
    case .getUserBalanceByCurrencyCode: return .get
    }
  }
  
  var queryParameters: Parameters? { return ["capability": "purchase"] }
  
  var service: String { return "payments" }
  
  var endpoint: String {
    switch self {
    case .getUserBalanceByCurrencyCode: return "/transaction-methods"
    }
  }
  
}

// MARK: - For Unit Tests

extension PaymentRouter {
  
  var testData: Data? {
    switch self {
    case .getUserBalanceByCurrencyCode: return readJSONFromFile("GetUserBalanceByCurrencyCodeResponse")
    }
  }
  
}
