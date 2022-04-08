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
  private(set) var colorsConfiguration = ColorsConfiguration()
  
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

// MARK: - Colors Configuration

public extension TLManager {
  
  /// Set background color for light and dark theme, default is Tilia background color
  /// - Parameters:
  ///   - lightModeColor: color for light mode
  ///   - darkModeColor: color for dark mode
  func setBackgroundColor(forLightMode lightModeColor: UIColor,
                          andDarkMode darkModeColor: UIColor) {
    colorsConfiguration.backgroundColor = .init(lightModeColor: lightModeColor,
                                                darkModeColor: darkModeColor)
  }
  
  /// Set primary color for light and dark theme, default is Tilia primary color
  /// - Parameters:
  ///   - lightModeColor: color for light mode
  ///   - darkModeColor: color for dark mode
  func setPrimaryColor(forLightMode lightModeColor: UIColor,
                       andDarkMode darkModeColor: UIColor) {
    colorsConfiguration.primaryColor = .init(lightModeColor: lightModeColor,
                                             darkModeColor: darkModeColor)
  }
  
  /// Set primary text color for light and dark theme, default is Tilia primary text color
  /// - Parameters:
  ///   - lightModeColor: color for light mode
  ///   - darkModeColor: color for dark mode
  func setPrimaryTextColor(forLightMode lightModeColor: UIColor,
                           andDarkMode darkModeColor: UIColor) {
    colorsConfiguration.primaryTextColor = .init(lightModeColor: lightModeColor,
                                                 darkModeColor: darkModeColor)
  }
  
  /// Set success background color for light and dark theme, default is Tilia success background color
  /// - Parameters:
  ///   - lightModeColor: color for light mode
  ///   - darkModeColor: color for dark mode
  func setSuccessBackgroundColor(forLightMode lightModeColor: UIColor,
                                 andDarkMode darkModeColor: UIColor) {
    colorsConfiguration.successBackgroundColor = .init(lightModeColor: lightModeColor,
                                                       darkModeColor: darkModeColor)
  }
  
  /// Set failure background color for light and dark theme, default is Tilia failure background color
  /// - Parameters:
  ///   - lightModeColor: color for light mode
  ///   - darkModeColor: color for dark mode
  func setFailureBackgroundColor(forLightMode lightModeColor: UIColor,
                                 andDarkMode darkModeColor: UIColor) {
    colorsConfiguration.failureBackgroundColor = .init(lightModeColor: lightModeColor,
                                                       darkModeColor: darkModeColor)
  }
  
}

// MARK: - Get User Info

public extension TLManager {
  
  /// Checks user needs to sign Terms Of Service, user access token is required
  /// - Parameters:
  ///   - completion: completion that returns user needs to sign TOS or error
  func getTosRequiredForUser(completion: @escaping (Result<Bool, Error>) -> Void) {
    getTos { completion($0.map { $0.isTosSigned }) }
  }
  
  /// Checks user balance by currency code, user access token is required
  /// - Parameters:
  ///   - currencyCode: currency code, for example USD
  ///   - completion: completion that returns user balance or error
  func getUserBalanceByCurrencyCode(_ currencyCode: String,
                                    completion: @escaping (Result<Double, Error>) -> Void) {
    getBalanceByCurrencyCode(currencyCode) { completion($0.map { $0.balance }) }
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
  
  /// Show Checkout flow, user access token is required
  /// - Parameters:
  ///   - viewController: view controller that is used for presenting Checkout flow
  ///   - invoiceId: authorized invoice id
  ///   - animated: animated flag
  ///   - completion: completion that returns Checkout is successfully completed
  func presentCheckoutViewController(on viewController: UIViewController,
                                     withInvoiceId invoiceId: String,
                                     animated: Bool,
                                     completion: ((Bool) -> Void)?) {
    let checkoutViewController = CheckoutViewController(invoiceId: invoiceId, completion: completion)
    viewController.present(checkoutViewController, animated: animated)
  }
  
}

// MARK: - Private Methods

private extension TLManager {
  
  func executeOnQueue(handler: @escaping () -> Void) {
    synchronizationQueue.async(flags: .barrier, execute: handler)
  }
  
}
