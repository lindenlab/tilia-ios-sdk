//
//  KycRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 13.07.2022.
//

import Alamofire

enum KycRouter: RouterProtocol {
  
  case submit(SubmitKycModel)
  case getStatus(String)
  
  var method: HTTPMethod {
    switch self {
    case .submit: return .post
    case .getStatus: return .get
    }
  }
  
  var queryParameters: Parameters? {
    switch self {
    case .submit: return nil
    case let .getStatus(id): return ["kyc_id" : id]
    }
  }
  
  var bodyParameters: Parameters? {
    switch self {
    case let .submit(model): return model.encodedParameters
    case .getStatus: return nil
    }
  }
  
  var service: String { return "pii" }
  
  var endpoint: String { return "/v2/kyc" }
  
}

// MARK: - For Unit Tests

extension KycRouter {
  
  var testData: Data? {
    switch self {
    case .submit:
      return readJSONFromFile("SubmittedKycResponse")
    case .getStatus:
      return readJSONFromFile("SubmittedKycStatusResponse")
    }
  }
  
}
