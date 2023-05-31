//
//  PaymentRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

enum PaymentRouter: RouterProtocol {
  
  case getUserBalanceByCurrencyCode
  case renamePaymentMethod(newName: String, id: String)
  case deletePaymentMethod(id: String)
  
  var method: HTTPMethod {
    switch self {
    case .getUserBalanceByCurrencyCode: return .get
    case .renamePaymentMethod: return .patch
    case .deletePaymentMethod: return .delete
    }
  }
  
  var queryParameters: Parameters? {
    switch self {
    case .getUserBalanceByCurrencyCode:
      return ["capability": "purchase"]
    case .renamePaymentMethod, .deletePaymentMethod:
      return nil
    }
  }
  
  var bodyParameters: Parameters? {
    switch self {
    case .getUserBalanceByCurrencyCode, .deletePaymentMethod:
      return nil
    case let .renamePaymentMethod(name, _):
      return ["display_string": name]
    }
  }
  
  var service: String { return "payments" }
  
  var endpoint: String {
    switch self {
    case .getUserBalanceByCurrencyCode:
      return "/transaction-methods"
    case .renamePaymentMethod(_, let id), .deletePaymentMethod(let id):
      return "/v1/payment_method/\(id)"
    }
  }
  
}

// MARK: - For Unit Tests

extension PaymentRouter {
  
  var testData: Data? {
    switch self {
    case .getUserBalanceByCurrencyCode:
      return readJSONFromFile("GetUserBalanceByCurrencyCodeResponse")
    case .renamePaymentMethod, .deletePaymentMethod:
      return readJSONFromFile("EmptySuccessResponse")
    }
  }
  
}
