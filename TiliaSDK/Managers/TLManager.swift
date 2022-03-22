//
//  TLManager.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Foundation

public typealias CompletionResultHandler<T> = (Result<T, Error>) -> Void

public final class TLManager {
  
  public static let shared = TLManager()
  
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

// MARK: - Get User Info

public extension TLManager {
  
  func getTosRequiredForUser(completion: @escaping CompletionResultHandler<TLTosModel>) {
    ServerClient.getTosRequiredForUser(completion: completion)
  }
  
  func getUserBalanceByCurrencyCode(_ currencyCode: String, completion: @escaping CompletionResultHandler<TLBalanceModel>) {
    ServerClient.getUserBalanceByCurrencyCode(currencyCode, completion: completion)
  }
  
}

private extension TLManager {
  
  func executeOnQueue(handler: () -> Void) {
    synchronizationQueue.sync(execute: handler)
  }
  
}
