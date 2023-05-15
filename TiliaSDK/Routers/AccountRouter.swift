//
//  AccountRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

enum AccountRouter: RouterProtocol {
  
  case getTosRequiredForUser
  case getTosContent
  case signTosForUser
  case getUserInfo
  case beginVerifyUserEmail(String)
  case finishVerifyUserEmail(model: FinishVerifyUserEmailModel)
  
  var method: HTTPMethod {
    switch self {
    case .getTosRequiredForUser, .getTosContent, .getUserInfo: return .get
    case .signTosForUser, .beginVerifyUserEmail, .finishVerifyUserEmail: return .post
    }
  }
  
  var bodyParameters: Parameters? {
    switch self {
    case .beginVerifyUserEmail(let email): return ["email": email]
    case .finishVerifyUserEmail(let model): return model.encodedParameters
    default: return nil
    }
  }
  
  var service: String { return "accounts" }
  
  var endpoint: String {
    switch self {
    case .getTosContent: return "/v1/tos"
    case .getTosRequiredForUser, .signTosForUser: return "/v1/user-info/tos/tilia"
    case .getUserInfo: return "/v1/user-info"
    case .beginVerifyUserEmail: return "/v1/user-info/email/begin-verify"
    case .finishVerifyUserEmail: return "/v1/user-info/email/finish-verify"
    }
  }
  
  func requestHeaders() throws -> [String : String] {
    switch self {
    case .getTosContent: return [:]
    default: return try defaultRequestHeaders()
    }
  }
  
}

// MARK: - For Unit Tests

extension AccountRouter {
  
  var testData: Data? {
    switch self {
    case .getTosRequiredForUser: return readJSONFromFile("GetTosRequiredForUserResponse")
    case .getTosContent: return readJSONFromFile("GetTosContentResponse")
    case .signTosForUser: return readJSONFromFile("SignTosForUserResponse")
    case .getUserInfo: return readJSONFromFile("GetUserInfoResponse")
    case .beginVerifyUserEmail: return readJSONFromFile("BeginVerifyUserEmailResponse")
    case .finishVerifyUserEmail: return readJSONFromFile("EmptySuccessResponse")
    }
  }
  
}
