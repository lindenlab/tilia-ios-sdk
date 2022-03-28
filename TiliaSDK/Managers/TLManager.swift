//
//  TLManager.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import UIKit

public typealias CompletionResultHandler<T> = (Result<T, Error>) -> Void

public final class TLManager {
  
  public static let shared = TLManager()
  
  var serverConfiguration: ServerConfiguration {
    return synchronizationQueue.sync { return _serverConfiguration }
  }
  
  private var _serverConfiguration = ServerConfiguration()
  private let synchronizationQueue = DispatchQueue(label: "TLManager#SynchronizationQueue", attributes: .concurrent)
  
  private init() { }
  
}

// MARK: - Server Configuration

public extension TLManager {
  
  func setToken(_ token: String) {
    executeOnQueue { self._serverConfiguration.token = token }
  }
  
  func setTimeoutInterval(_ timeoutInterval: Double) {
    executeOnQueue { self._serverConfiguration.timeoutInterval = timeoutInterval }
  }
  
  func setEnvironment(_ environment: TLEnvironment) {
    executeOnQueue { self._serverConfiguration.environment = environment }
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

// MARK: - View Controllers

public extension TLManager {
  
  func showTosIsRequired(on viewController: UIViewController, animated: Bool) {
    let tosViewController = TosViewController()
    viewController.present(tosViewController, animated: animated)
  }
  
}

private extension TLManager {
  
  func executeOnQueue(handler: @escaping () -> Void) {
    synchronizationQueue.async(flags: .barrier, execute: handler)
  }
  
}
