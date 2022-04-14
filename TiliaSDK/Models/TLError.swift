//
//  TLError.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Foundation

/// Tilia error
public enum TLError: Error {
  
  /// Invalid or empty token
  case invalidToken
  
  /// Invalid or empty parameters
  case invalidParameters
  
  /// Decodable data is nil
  case decodableDataIsNil
  
  /// Server error with localized description
  /// - Parameters:
  ///   - error: localized description
  case serverError(String)
  
  /// User balance does not exist for currency code
  /// - Parameters:
  ///   - currency: currency code
  case userBalanceDoesNotExistForCurrency(String)
  
}

// MARK: - LocalizedError

extension TLError: LocalizedError {
  
  public var errorDescription: String? {
    switch self {
    case .invalidToken:
      return "Invalid or empty token"
    case .invalidParameters:
      return "Invalid or empty parameters"
    case .decodableDataIsNil:
      return "Something went wrong"
    case .serverError(let error):
      return error
    case .userBalanceDoesNotExistForCurrency(let currency):
      return "User balance does not exist for currency: \(currency)"
    }
  }
  
}
