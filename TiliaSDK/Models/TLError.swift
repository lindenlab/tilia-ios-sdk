//
//  TLError.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Foundation

public enum TLError: Error {
  
  case invalidToken
  case decodableDataIsNil
  case serverError(String)
  case userBalanceDoesNotExistForCurrency(String)
  
}

// MARK: - LocalizedError

extension TLError: LocalizedError {
  
  public var errorDescription: String? {
    switch self {
    case .invalidToken:
      return "Invalid or empty token"
    case .decodableDataIsNil:
      return "Something went wrong"
    case .serverError(let error):
      return error
    case .userBalanceDoesNotExistForCurrency(let currency):
      return "User balance does not exist for currency: \(currency)"
    }
  }
  
}
