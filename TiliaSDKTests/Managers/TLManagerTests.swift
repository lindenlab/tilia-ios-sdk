//
//  TLManagerTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 11.04.2022.
//

import XCTest
@testable import TiliaSDK

final class TLManagerTests: XCTestCase {
  
  func testSetToken() {
    let token = UUID().uuidString
    TLManager.shared.setToken(token)
    XCTAssertEqual(TLManager.shared.networkManager.serverConfiguration.token, token)
  }
  
  func testSetTimeoutInterval() {
    let interval = 10.0
    TLManager.shared.setTimeoutInterval(interval)
    XCTAssertEqual(TLManager.shared.networkManager.serverConfiguration.timeoutInterval, interval)
  }
  
  func testSetEnvironment() {
    let environment = TLEnvironment.production
    TLManager.shared.setEnvironment(environment)
    XCTAssertEqual(TLManager.shared.networkManager.serverConfiguration.environment, environment)
  }
  
  func testSetBackgroundColor() {
    let traitCollection = UITraitCollection()
    TLManager.shared.setBackgroundColor(forLightMode: .red, andDarkMode: .red)
    if traitCollection.userInterfaceStyle == .dark {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.backgroundColor?.darkModeColor.cgColor, UIColor.backgroundColor.cgColor)
    } else {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.backgroundColor?.lightModeColor.cgColor, UIColor.backgroundColor.cgColor)
    }
  }
  
  func testSetPrimaryColor() {
    let traitCollection = UITraitCollection()
    TLManager.shared.setPrimaryColor(forLightMode: .green, andDarkMode: .green)
    if traitCollection.userInterfaceStyle == .dark {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.primaryColor?.darkModeColor.cgColor, UIColor.primaryColor.cgColor)
    } else {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.primaryColor?.lightModeColor.cgColor, UIColor.primaryColor.cgColor)
    }
  }
  
  // TODO: - Temporary removed
//  func testSetPrimaryTextColor() {
//    let traitCollection = UITraitCollection()
//    TLManager.shared.setPrimaryTextColor(forLightMode: .yellow, andDarkMode: .yellow)
//    if traitCollection.userInterfaceStyle == .dark {
//      XCTAssertEqual(TLManager.shared.colorsConfiguration.primaryTextColor?.darkModeColor.cgColor, UIColor.primaryTextColor.cgColor)
//    } else {
//      XCTAssertEqual(TLManager.shared.colorsConfiguration.primaryTextColor?.lightModeColor.cgColor, UIColor.primaryTextColor.cgColor)
//    }
//  }
  
  func testSetSuccessBackgroundColor() {
    let traitCollection = UITraitCollection()
    TLManager.shared.setSuccessBackgroundColor(forLightMode: .orange, andDarkMode: .orange)
    if traitCollection.userInterfaceStyle == .dark {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.successBackgroundColor?.darkModeColor.cgColor, UIColor.successBackgroundColor.cgColor)
    } else {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.successBackgroundColor?.lightModeColor.cgColor, UIColor.successBackgroundColor.cgColor)
    }
  }
  
  func testSetFailureBackgroundColor() {
    let traitCollection = UITraitCollection()
    TLManager.shared.setFailureBackgroundColor(forLightMode: .gray, andDarkMode: .gray)
    if traitCollection.userInterfaceStyle == .dark {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.failureBackgroundColor?.darkModeColor.cgColor, UIColor.failureBackgroundColor.cgColor)
    } else {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.failureBackgroundColor?.lightModeColor.cgColor, UIColor.failureBackgroundColor.cgColor)
    }
  }
  
  func testGetTosRequiredForUserTokenIsEmpty() {
    TLManager.shared.setToken("")
    var tokenError: Error?
    let expectation = XCTestExpectation(description: "testGetTosRequiredForUserTokenIsEmpty")
    TLManager.shared.getTosRequiredForUser { result in
      expectation.fulfill()
      switch result {
      case .failure(let error):
        tokenError = error
      case .success:
        break
      }
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertNotNil(tokenError)
  }
  
  func testGetUserBalanceByCurrencyCodeIsEmpty() {
    TLManager.shared.setToken(UUID().uuidString)
    var currencyCodeError: Error?
    let expectation = XCTestExpectation(description: "testGetUserBalanceByCurrencyCodeIsEmpty")
    TLManager.shared.getUserBalanceByCurrencyCode("") { result in
      expectation.fulfill()
      switch result {
      case .failure(let error):
        currencyCodeError = error
      case .success:
        break
      }
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertNotNil(currencyCodeError)
  }
  
  func testMissedRequiredDataForTosFlow() {
    TLManager.shared.setToken("")
    var errorCallback: TLErrorCallback?
    let expectation = XCTestExpectation(description: "testMissedRequiredDataForTosFlow")
    TLManager.shared.presentTosIsRequiredViewController(on: UIViewController(),
                                                        animated: true,
                                                        onError: { errorCallback = $0; expectation.fulfill() })
    wait(for: [expectation], timeout: 1)
    XCTAssertNotNil(errorCallback)
  }
  
  func testMissedRequiredDataForCheckoutFlow() {
    var errorCallback: TLErrorCallback?
    let expectation = XCTestExpectation(description: "testMissedRequiredDataForCheckoutFlow")
    TLManager.shared.presentCheckoutViewController(on: UIViewController(),
                                                   withInvoiceId: "",
                                                   animated: true,
                                                   onError: { errorCallback = $0; expectation.fulfill() })
    wait(for: [expectation], timeout: 1)
    XCTAssertNotNil(errorCallback)
  }
  
  func testMissedRequiredDataForKycFlow() {
    TLManager.shared.setToken("")
    var errorCallback: TLErrorCallback?
    let expectation = XCTestExpectation(description: "testMissedRequiredDataForKycFlow")
    TLManager.shared.presentKycViewController(on: UIViewController(),
                                              animated: true,
                                              onError: { errorCallback = $0; expectation.fulfill() })
    wait(for: [expectation], timeout: 1)
    XCTAssertNotNil(errorCallback)
  }
  
  func testMissedRequiredDataForTransactionDetailsFlow() {
    var errorCallback: TLErrorCallback?
    let expectation = XCTestExpectation(description: "testMissedRequiredDataForTransactionDetailsFlow")
    TLManager.shared.presentTransactionDetailsViewController(on: UIViewController(),
                                                             withTransactionId: "",
                                                             animated: true,
                                                             onError: { errorCallback = $0; expectation.fulfill() })
    wait(for: [expectation], timeout: 1)
    XCTAssertNotNil(errorCallback)
  }
  
  func testMissedRequiredDataForTransactionHistoryFlow() {
    TLManager.shared.setToken("")
    var errorCallback: TLErrorCallback?
    let expectation = XCTestExpectation(description: "testMissedRequiredDataForTransactionHistoryFlow")
    TLManager.shared.presentTransactionHistoryViewController(on: UIViewController(),
                                                             animated: true,
                                                             onError: { errorCallback = $0; expectation.fulfill() })
    wait(for: [expectation], timeout: 1)
    XCTAssertNotNil(errorCallback)
  }
  
}
