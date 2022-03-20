//
//  TLManager.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Foundation

public final class TLManager {
  
  static let shared = TLManager()
  
  private(set) lazy var serverConfiguration = ServerConfiguration()
  
  private init() { }
  
}

// MARK: - Server Configuration

public extension TLManager {
  
  func setToken(_ token: String) {
    serverConfiguration.token = token
  }
  
  func setTimeoutInterval(_ timeoutInterval: Double) {
    serverConfiguration.timeoutInterval = timeoutInterval
  }
  
  func setEnvironment(_ environment: TLEnvironment) {
    serverConfiguration.environment = environment
  }
  
}
