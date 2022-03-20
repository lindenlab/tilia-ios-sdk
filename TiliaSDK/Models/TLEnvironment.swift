//
//  TLEnvironment.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Foundation

public enum TLEnvironment {
  
  case staging
  case production
  
}

extension TLEnvironment {
  
  var description: String {
    switch self {
    case .staging: return "staging.tilia-inc"
    case .production: return "tilia-inc"
    }
  }
  
}
