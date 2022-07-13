//
//  KycRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 13.07.2022.
//

import Alamofire

enum KycRouter: RouterProtocol {
  
  case upload(KycUploadModel)
  case getState(String)
  
  var method: HTTPMethod {
    switch self {
    case .upload: return .post
    case .getState: return .get
    }
  }
  
  var queryParameters: Parameters? {
    switch self {
    case .upload: return nil
    case let .getState(id): return ["kyc_id" : id]
    }
  }
  
  var bodyParameters: Parameters? {
    switch self {
    case let .upload(model): return model.encodedParameters
    case .getState: return nil
    }
  }
  
  var service: String { return "" } // TODO: - Fix me
  
  var endpoint: String { return "/v2/kyc" }
  
}
