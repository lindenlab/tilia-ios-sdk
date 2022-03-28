//
//  TosAcceptModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 28.03.2022.
//

import Foundation

enum TosAcceptModel: String, CaseIterable {
  
  case termsOfService = "Terms of Service"
  case privacyPolicy = "Privacy Policy"
  
  static var title: String { return "I agree to Tilia Inc.'s Terms of Service and acknowledge receipt of Tilia Inc.'s Privacy Policy." }
  
  var url: URL {
    switch self {
    case .termsOfService:
      return URL(string: "https://www.tilia.io/legal/tos")!
    case .privacyPolicy:
      return URL(string: "https://www.tilia.io/legal/privacy")!
    }
  }
  
}
