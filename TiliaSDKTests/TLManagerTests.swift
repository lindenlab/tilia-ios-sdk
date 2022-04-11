//
//  TLManagerTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 11.04.2022.
//

import XCTest
@testable import TiliaSDK

class TLManagerTests: XCTestCase {
  
  func testSetToken() {
    XCTAssertNil(TLManager.shared.networkManager.serverConfiguration.token)
    let token = UUID().uuidString
    TLManager.shared.setToken(token)
    XCTAssertNotNil(TLManager.shared.networkManager.serverConfiguration.token)
  }
  
  func testSetTimeoutInterval() {
    let defaultInterval = 30.0
    XCTAssertEqual(TLManager.shared.networkManager.serverConfiguration.timeoutInterval, defaultInterval)
    let interval = 10.0
    TLManager.shared.setTimeoutInterval(interval)
    XCTAssertEqual(TLManager.shared.networkManager.serverConfiguration.timeoutInterval, interval)
  }
  
  func testSetEnvironment() {
    let defaultEnvironment = TLEnvironment.staging
    XCTAssertEqual(TLManager.shared.networkManager.serverConfiguration.environment.description, defaultEnvironment.description)
    let environment = TLEnvironment.production
    TLManager.shared.setEnvironment(environment)
    XCTAssertEqual(TLManager.shared.networkManager.serverConfiguration.environment.description, environment.description)
  }
  
  func testSetBackgroundColor() {
    let traitCollection = UITraitCollection()
    XCTAssertNil(TLManager.shared.colorsConfiguration.backgroundColor)
    TLManager.shared.setBackgroundColor(forLightMode: .red, andDarkMode: .red)
    if traitCollection.userInterfaceStyle == .dark {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.backgroundColor?.darkModeColor.cgColor, UIColor.backgroundColor.cgColor)
    } else {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.backgroundColor?.lightModeColor.cgColor, UIColor.backgroundColor.cgColor)
    }
  }
  
  func testSetPrimaryColor() {
    let traitCollection = UITraitCollection()
    XCTAssertNil(TLManager.shared.colorsConfiguration.primaryColor)
    TLManager.shared.setPrimaryColor(forLightMode: .green, andDarkMode: .green)
    if traitCollection.userInterfaceStyle == .dark {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.primaryColor?.darkModeColor.cgColor, UIColor.primaryColor.cgColor)
    } else {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.primaryColor?.lightModeColor.cgColor, UIColor.primaryColor.cgColor)
    }
  }
  
  func testSetPrimaryTextColor() {
    let traitCollection = UITraitCollection()
    XCTAssertNil(TLManager.shared.colorsConfiguration.primaryTextColor)
    TLManager.shared.setPrimaryTextColor(forLightMode: .yellow, andDarkMode: .yellow)
    if traitCollection.userInterfaceStyle == .dark {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.primaryTextColor?.darkModeColor.cgColor, UIColor.primaryTextColor.cgColor)
    } else {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.primaryTextColor?.lightModeColor.cgColor, UIColor.primaryTextColor.cgColor)
    }
  }
  
  func testSetSuccessBackgroundColor() {
    let traitCollection = UITraitCollection()
    XCTAssertNil(TLManager.shared.colorsConfiguration.successBackgroundColor)
    TLManager.shared.setSuccessBackgroundColor(forLightMode: .orange, andDarkMode: .orange)
    if traitCollection.userInterfaceStyle == .dark {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.successBackgroundColor?.darkModeColor.cgColor, UIColor.successBackgroundColor.cgColor)
    } else {
      XCTAssertEqual(TLManager.shared.colorsConfiguration.successBackgroundColor?.lightModeColor.cgColor, UIColor.successBackgroundColor.cgColor)
    }
  }
  
  func testSetFailureBackgroundColor() {
    let traitCollection = UITraitCollection()
    XCTAssertNil(TLManager.shared.colorsConfiguration.failureBackgroundColor)
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
    let expactation = XCTestExpectation(description: "testGetTosRequiredForUserTokenIsEmpty")
    TLManager.shared.getTosRequiredForUser { result in
      expactation.fulfill()
      switch result {
      case .failure(let error):
        tokenError = error
      case .success:
        break
      }
    }
    wait(for: [expactation], timeout: 1)
    XCTAssertNotNil(tokenError)
  }
  
  func testGetUserBalanceByCurrencyCodeIsEmpty() {
    TLManager.shared.setToken("")
    var tokenError: Error?
    let expactation = XCTestExpectation(description: "testGetUserBalanceByCurrencyCodeIsEmpty")
    TLManager.shared.getUserBalanceByCurrencyCode("") { result in
      expactation.fulfill()
      switch result {
      case .failure(let error):
        tokenError = error
      case .success:
        break
      }
    }
    wait(for: [expactation], timeout: 1)
    XCTAssertNotNil(tokenError)
  }
  
}
