//
//  TosAcceptModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 28.03.2022.
//

import Foundation

enum TosAcceptModel: CaseIterable {
  
  case termsOfService
  case privacyPolicy
  
  static var title: String { return L.tosAcceptDescription }
  static var payTitle: String { return L.payAcceptDescription }
  
  var description: String {
    switch self {
    case .termsOfService: return L.tos
    case .privacyPolicy: return L.privacyPolicy
    }
  }
  
  var url: URL {
    switch self {
    case .termsOfService:
      return URL(string: "https://www.tilia.io/legal/tos")!
    case .privacyPolicy:
      return URL(string: "https://www.tilia.io/legal/privacy")!
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
