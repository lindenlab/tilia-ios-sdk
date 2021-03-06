//
//  TLUpdateCallback.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 14.04.2022.
//

import Foundation

/// Tilia update callback model
public struct TLUpdateCallback {
  
  /// Event model
  public let event: TLEvent
  
  /// Message
  public let message: String
  
}

// MARK: - CustomStringConvertible

extension TLUpdateCallback: CustomStringConvertible {
  
  public var description: String {
    return "Event: \(event.description)\nMessage: \(message)"
  }
  
}
