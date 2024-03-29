//
//  TosAcceptModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 28.03.2022.
//

import Foundation

enum TosAcceptModel: CustomStringConvertible, CaseIterable {
  
  case termsOfService
  case privacyPolicy
  
  static var title: String { return L.tosAcceptDescription }
  static var privacyPolicyUrl: URL { return URL(string: "https://www.tilia.io/legal/privacy")! }
  static var termsOfServiceUrl: URL { return URL(string: "https://www.tilia.io/legal/tos/raw")! }
  
  var description: String {
    switch self {
    case .termsOfService: return L.tos
    case .privacyPolicy: return L.privacyPolicy
    }
  }
  
  init?(str: String) {
    switch str {
    case TosAcceptModel.termsOfService.description: self = .termsOfService
    case TosAcceptModel.privacyPolicy.description: self = .privacyPolicy
    default: return nil
    }
  }
  
}
