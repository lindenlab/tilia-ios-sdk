//
//  VerifyEmailValidatorTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 17.05.2023.
//

import XCTest
@testable import TiliaSDK

final class VerifyEmailValidatorTests: XCTestCase {
  
  func testIsCodeValid() {
    let isValid = VerifyEmailValidator().isCodeValid("123456")
    XCTAssertTrue(isValid)
  }
  
  func testIsCodeInvalid() {
    let isValid = VerifyEmailValidator().isCodeValid("123")
    XCTAssertFalse(isValid)
  }
  
  func testCanEnterMore() {
    let isValid = VerifyEmailValidator().canEnterMore("123")
    XCTAssertTrue(isValid)
  }
  
  func testCanNotEnterMore() {
    let isValid = VerifyEmailValidator().canEnterMore("1234567")
    XCTAssertFalse(isValid)
  }
  
}
