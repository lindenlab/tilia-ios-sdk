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
  
  /// Decodable data is nil
  case decodableDataIsNil
  
  /// Server error with localized description
  /// - Parameters:
  ///   - error: localized description
  case serverError(String)
  
  /// Invalid or empty currency code
  case invalidCurrencyCode
  
  /// User balance does not exist for currency code
  /// - Parameters:
  ///   - currency: currency code
  case userBalanceDoesNotExistForCurrency(String)
  
  /// URL does not exist for string
  /// - Parameters:
  ///   - str: string representation of URL
  case urlDoesNotExistForString(String)
  
}

// MARK: - LocalizedError

extension TLError: LocalizedError {
  
  public var errorDescription: String? {
    switch self {
    case .invalidToken:
      return "Invalid or empty token"
    case .invalidCurrencyCode:
      return "Invalid or empty parameters"
    case .decodableDataIsNil:
      return "Something went wrong"
    case .serverError(let error):
      return error
    case .userBalanceDoesNotExistForCurrency(let currency):
      return "User balance does not exist for currency: \(currency)"
    case .urlDoesNotExistForString(let str):
      return "URL does not exist for string: \(str)"
    }
  }
  
}
