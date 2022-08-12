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
  
  var networkManager: NetworkManager {
    return synchronizationQueue.sync { return _networkManager }
  }
  var colorsConfiguration: ColorsConfiguration {
    return synchronizationQueue.sync { return _colorsConfiguration }
  }
  
  private let _networkManager = NetworkManager(serverClient: ServerClient())
  private let _colorsConfiguration = ColorsConfiguration()
  private let synchronizationQueue = DispatchQueue(label: "TLManager#SynchronizationQueue", attributes: .concurrent)
  
  private init() { }
  
}

// MARK: - Server Configuration

public extension TLManager {
  
  /// Sets user access token that used to call Tilia API, default is nil
  /// - Parameters:
  ///   - token: user access token
  func setToken(_ token: String) {
    executeOnQueue { self._networkManager.serverConfiguration.token = token }
  }
  
  /// Sets timeout interval (in seconds) for requests, default is 30 seconds
  /// - Parameters:
  ///   - timeoutInterval: timeout interval
  func setTimeoutInterval(_ timeoutInterval: Double) {
    executeOnQueue { self._networkManager.serverConfiguration.timeoutInterval = timeoutInterval }
  }
  
  /// Sets environment - staging or production, default is staging
  /// - Parameters:
  ///   - environment: environment
  func setEnvironment(_ environment: TLEnvironment) {
    executeOnQueue { self._networkManager.serverConfiguration.environment = environment }
  }
  
}

// MARK: - Colors Configuration

public extension TLManager {
  
  /// Set background color for light and dark theme, default is Tilia background color
  /// - Parameters:
  ///   - lightModeColor: color for light mode
  ///   - darkModeColor: color for dark mode
  func setBackgroundColor(forLightMode lightModeColor: UIColor,
                          andDarkMode darkModeColor: UIColor) {
    executeOnQueue { self._colorsConfiguration.backgroundColor = .init(lightModeColor: lightModeColor, darkModeColor: darkModeColor) }
  }
  
  /// Set primary color for light and dark theme, default is Tilia primary color
  /// - Parameters:
  ///   - lightModeColor: color for light mode
  ///   - darkModeColor: color for dark mode
  func setPrimaryColor(forLightMode lightModeColor: UIColor,
                       andDarkMode darkModeColor: UIColor) {
    executeOnQueue { self._colorsConfiguration.primaryColor = .init(lightModeColor: lightModeColor, darkModeColor: darkModeColor) }
  }
  
  /// Set success background color for light and dark theme, default is Tilia success background color
  /// - Parameters:
  ///   - lightModeColor: color for light mode
  ///   - darkModeColor: color for dark mode
  func setSuccessBackgroundColor(forLightMode lightModeColor: UIColor,
                                 andDarkMode darkModeColor: UIColor) {
    executeOnQueue { self._colorsConfiguration.successBackgroundColor = .init(lightModeColor: lightModeColor, darkModeColor: darkModeColor) }
  }
  
  /// Set failure background color for light and dark theme, default is Tilia failure background color
  /// - Parameters:
  ///   - lightModeColor: color for light mode
  ///   - darkModeColor: color for dark mode
  func setFailureBackgroundColor(forLightMode lightModeColor: UIColor,
                                 andDarkMode darkModeColor: UIColor) {
    executeOnQueue { self._colorsConfiguration.failureBackgroundColor = .init(lightModeColor: lightModeColor, darkModeColor: darkModeColor) }
  }
  
}

// MARK: - Get User Info

public extension TLManager {
  
  /// Checks user needs to sign Terms Of Service, user access token is required
  /// - Parameters:
  ///   - completion: completion that returns user needs to sign TOS or error
  func getTosRequiredForUser(completion: @escaping (Result<Bool, Error>) -> Void) {
    networkManager.getTosRequiredForUser { completion($0.map { $0.isTosSigned }) }
  }
  
  /// Get Terms Of Service content, user access token is not required
  /// - Parameters:
  ///   - completion: completion that returns TOS content or error
  func getTosContent(completion: @escaping (Result<String, Error>) -> Void) {
    networkManager.getTosContent { completion($0.map { $0.content }) }
  }
  
  /// Checks user balance by currency code, user access token is required
  /// - Parameters:
  ///   - currencyCode: currency code, for example USD
  ///   - completion: completion that returns user balance or error
  func getUserBalanceByCurrencyCode(_ currencyCode: String,
                                    completion: @escaping (Result<Double, Error>) -> Void) {
    networkManager.getUserBalanceByCurrencyCode(currencyCode) { completion($0.map { $0.balance }) }
  }
  
}

// MARK: - User's flows

public extension TLManager {
  
  /// Show flow to sign Terms Of Service for user, user access token is required
  /// - Parameters:
  ///   - viewController: view controller that is used for presenting TOS flow
  ///   - animated: animated flag
  ///   - onComplete: completion that returns TOS flow state
  ///   - onError: completion that returns TOS flow error
  func presentTosIsRequiredViewController(on viewController: UIViewController,
                                          animated: Bool,
                                          onComplete: ((TLCompleteCallback) -> Void)? = nil,
                                          onError: ((TLErrorCallback) -> Void)? = nil) {
    guard let token = networkManager.serverConfiguration.token, !token.isEmpty else {
      let errorCallback = TLErrorCallback(event: TLEvent(flow: .tos, action: .missingRequiredData),
                                          error: L.errorTosTitle,
                                          message: L.missedRequiredData)
      onError?(errorCallback)
      return
    }
    
    let tosViewController = TosViewController(manager: networkManager,
                                              onComplete: onComplete,
                                              onError: onError)
    viewController.present(tosViewController, animated: animated)
  }
  
  /// Show Checkout flow, user access token is required
  /// - Parameters:
  ///   - viewController: view controller that is used for presenting Checkout flow
  ///   - invoiceId: authorized invoice id
  ///   - animated: animated flag
  ///   - onUpdate: completion that returns Checkout payment is processed
  ///   - onComplete: completion that returns Checkout flow state
  ///   - onError: completion that returns Checkout flow error
  func presentCheckoutViewController(on viewController: UIViewController,
                                     withInvoiceId invoiceId: String,
                                     animated: Bool,
                                     onUpdate: ((TLUpdateCallback) -> Void)? = nil,
                                     onComplete: ((TLCompleteCallback) -> Void)? = nil,
                                     onError: ((TLErrorCallback) -> Void)? = nil) {
    guard let token = networkManager.serverConfiguration.token, !token.isEmpty, !invoiceId.isEmpty else {
      let errorCallback = TLErrorCallback(event: TLEvent(flow: .checkout, action: .missingRequiredData),
                                          error: L.errorPaymentTitle,
                                          message: L.missedRequiredData)
      onError?(errorCallback)
      return
    }
    
    let checkoutViewController = CheckoutViewController(invoiceId: invoiceId,
                                                        manager: networkManager,
                                                        onUpdate: onUpdate,
                                                        onComplete: onComplete,
                                                        onError: onError)
    viewController.present(checkoutViewController, animated: animated)
  }
  
}

// MARK: - Private Methods

private extension TLManager {
  
  func executeOnQueue(handler: @escaping () -> Void) {
    synchronizationQueue.async(flags: .barrier, execute: handler)
  }
  
}
