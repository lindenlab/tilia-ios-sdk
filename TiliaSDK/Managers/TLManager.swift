//
//  TLManager.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Foundation

public final class TLManager {
  
  static let shared = TLManager()
  
  private(set) var serverConfiguration = ServerConfiguration()
  private let synchronizationQueue = DispatchQueue(label: "TLManager#SynchronizationQueue")
  
  private init() { }
  
}

// MARK: - Server Configuration

public extension TLManager {
  
  func setToken(_ token: String) {
    executeOnQueue { serverConfiguration.token = token }
  }
  
  func setTimeoutInterval(_ timeoutInterval: Double) {
    executeOnQueue { serverConfiguration.timeoutInterval = timeoutInterval }
  }
  
  func setEnvironment(_ environment: TLEnvironment) {
    executeOnQueue { serverConfiguration.environment = environment }
  }
  
}

private extension TLManager {
  
  func executeOnQueue(handler: () -> Void) {
    synchronizationQueue.sync(execute: handler)
  }
  
}
