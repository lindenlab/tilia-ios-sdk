//
//  UIColorTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 27.10.2022.
//

import XCTest
@testable import TiliaSDK

final class UIColorTests: XCTestCase {
  
  func testHexInit() {
    let color = UIColor(hexString: "#ffffff")
    let whiteColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    XCTAssertEqual(color.cgColor, whiteColor.cgColor)
  }
  
  func testColorDarkness() {
    XCTAssertTrue(UIColor.black.isColorDark)
    XCTAssertFalse(UIColor.white.isColorDark)
  }
  
}
