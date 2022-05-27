//
//  TLEnvironment.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Foundation

/// Tilia environment
public enum TLEnvironment {
  
  /// Staging environment
  case staging
  
  /// Production environment
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
