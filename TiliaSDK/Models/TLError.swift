//
//  TLError.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Foundation

public enum TLError: Error {
  
  case invalidToken
  
}

// MARK: -

extension TLError: LocalizedError {
  
  public var errorDescription: String? {
    switch self {
    case .invalidToken:
      return "Invalid or empty token"
    }
  }
  
}
