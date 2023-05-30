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
  
  /// Additional data
  public let data: Any?
  
  init(event: TLEvent, state: State, data: Any? = nil) {
    self.event = event
    self.state = state
    self.data = data
  }
  
}

// MARK: - CustomStringConvertible

extension TLCompleteCallback: CustomStringConvertible {
  
  public var description: String {
    let dataStr = (data as? CustomStringConvertible).map { "\nData: \($0.description)" } ?? ""
    return "Event: \(event.description)\nState: \(state.rawValue)" + dataStr
  }
  
}
