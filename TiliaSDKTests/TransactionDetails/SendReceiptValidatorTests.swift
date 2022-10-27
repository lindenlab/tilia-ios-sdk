//
//  SendReceiptValidatorTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 26.08.2022.
//

import XCTest
@testable import TiliaSDK

final class SendReceiptValidatorTests: XCTestCase {
  
  func testSuccess() {
    let isValid = SendReceiptValidator.isEmailValid("test@gmail.com")
    XCTAssertTrue(isValid)
  }
  
  func testFailure() {
    let isValid = SendReceiptValidator.isEmailValid("test")
    XCTAssertFalse(isValid)
  }
  
}
