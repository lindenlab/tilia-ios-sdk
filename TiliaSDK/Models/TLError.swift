//
//  TLError.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Foundation

public enum TLError: Error {
  
  case invalidToken
  
  case serverBaseResponseIsNil
  case serverBaseResponseDecodingFailed
  case serverError(String)
  
}

// MARK: -

extension TLError: LocalizedError {
  
  public var errorDescription: String? {
    switch self {
    case .invalidToken:
      return "Invalid or empty token"
    case .serverBaseResponseIsNil, .serverBaseResponseDecodingFailed:
      return "Something went wrong"
    case .serverError(let error):
      return error
    }
  }
  
}
