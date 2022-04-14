//
//  TLCompleteCallback.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 14.04.2022.
//

import Foundation

/// Tilia complete callback model
public struct TLCompleteCallback {
  
  /// State
  public enum State: String {
    
    /// Error state
    case error
    
    /// Cancelled state
    case cancelled
    
    /// Completed state
    case completed
    
  }
  
  /// Event model
  public let event: TLEvent
  
  /// State model
  public let state: State
  
}

// MARK: - CustomStringConvertible

extension TLCompleteCallback: CustomStringConvertible {
  
  public var description: String {
    return "Event: \(event.description)\nState: \(state.rawValue)"
  }
  
}
