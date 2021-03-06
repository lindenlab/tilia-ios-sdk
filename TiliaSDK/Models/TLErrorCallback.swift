//
//  TLErrorCallback.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 14.04.2022.
//

import Foundation

/// Tilia error callback model
public struct TLErrorCallback {
  
  /// Event model
  public let event: TLEvent
  
  /// Error title
  public let error: String
  
  /// Error message
  public let message: String
  
}

// MARK: - CustomStringConvertible

extension TLErrorCallback: CustomStringConvertible {
  
  public var description: String {
    return "Event: \(event.description)\nError: \(error)\nMessage: \(message)"
  }
  
}
