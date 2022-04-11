//
//  UIColorTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 11.04.2022.
//

import XCTest
@testable import TiliaSDK

class UIColorTests: XCTestCase {
  
  func testIsColorDark() {
    let whiteColor = UIColor.white
    let blackColor = UIColor.black
    XCTAssertFalse(whiteColor.isColorDark())
    XCTAssertTrue(blackColor.isColorDark())
  }
  
}
