//
//  SettingsRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 12.05.2023.
//

import Alamofire

enum SettingsRouter: RouterProtocol {
  
  case getSettings
  
  var method: HTTPMethod {
    switch self {
    case .getSettings: return .get
    }
  }
  
  var service: String {
    switch self {
    case .getSettings: return "web"
    }
  }
  
  var endpoint: String {
    switch self {
    case .getSettings: return "/ui/api/settings/acweb"
    }
  }
  
  func requestHeaders() throws -> [String : String] {
    switch self {
    case .getSettings: return [:]
    }
  }
  
}

// MARK: - For Unit Tests

extension SettingsRouter {
  
  var testData: Data? {
    switch self {
    case .getSettings:
      return readJSONFromFile("GetSettingsResponse")
    }
  }
  
}
