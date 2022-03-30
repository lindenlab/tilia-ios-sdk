//
//  TLManager.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import UIKit

/// Tilia manager
public final class TLManager {
  
  /// Use this instance for calling Tilia API or present user's flows
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
  
  /// Sets user access token that used to call Tilia API, default is nil
  /// - Parameters:
  ///   - token: user access token
  func setToken(_ token: String) {
    executeOnQueue { self._serverConfiguration.token = token }
  }
  
  /// Sets timeout interval (in seconds) for requests, default is 30 seconds
  /// - Parameters:
  ///   - timeoutInterval: timeout interval
  func setTimeoutInterval(_ timeoutInterval: Double) {
    executeOnQueue { self._serverConfiguration.timeoutInterval = timeoutInterval }
  }
  
  /// Sets environment - staging or production, default is staging
  /// - Parameters:
  ///   - environment: environment
  func setEnvironment(_ environment: TLEnvironment) {
    executeOnQueue { self._serverConfiguration.environment = environment }
  }
  
}

// MARK: - Get User Info

public extension TLManager {
  
  /// Checks user needs to sign Terms Of Service, user access token is required
  /// - Parameters:
  ///   - completion: completion that returns user needs to sign TOS or error
  func getTosRequiredForUser(completion: @escaping (Result<Bool, Error>) -> Void) {
    getTosModel { completion($0.map { $0.isTosSigned }) }
  }
  
  /// Checks user balance by currency code, user access token is required
  /// - Parameters:
  ///   - currencyCode: currency code, for example USD
  ///   - completion: completion that returns user balance or error
  func getUserBalanceByCurrencyCode(_ currencyCode: String,
                                    completion: @escaping (Result<Double, Error>) -> Void) {
    getBalanceModelByCurrencyCode(currencyCode) { completion($0.map { $0.balance }) }
  }
  
}

// MARK: - User's flows

public extension TLManager {
  
  /// Show flow to sign Terms Of Service for user, user access token is required
  /// - Parameters:
  ///   - viewController: view controller that is used for presenting TOS flow
  ///   - animated: animated flag
  ///   - completion: completion that returns TOS is successfully accepted
  func presentTosIsRequiredViewController(on viewController: UIViewController,
                                          animated: Bool,
                                          completion: ((Bool) -> Void)?) {
    let tosViewController = TosViewController(completion: completion)
    viewController.present(tosViewController, animated: animated)
  }
  
}

// MARK: - Private Methods

private extension TLManager {
  
  func executeOnQueue(handler: @escaping () -> Void) {
    synchronizationQueue.async(flags: .barrier, execute: handler)
  }
  
}
