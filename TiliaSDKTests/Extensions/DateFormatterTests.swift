//
//  DateFormatterTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 28.10.2022.
//

import XCTest
@testable import TiliaSDK

final class DateFormatterTests: XCTestCase {
  
  func testLongDateFormatter() {
    let formatter = DateFormatter.longDateFormatter
    XCTAssertEqual(formatter.dateStyle, .long)
    XCTAssertEqual(formatter.timeStyle, .none)
  }
  
  func testShortTimeFormatter() {
    let formatter = DateFormatter.shortTimeFormatter
    XCTAssertEqual(formatter.dateStyle, .none)
    XCTAssertEqual(formatter.timeStyle, .short)
  }
  
  func testLongDateAndShortTimeFormatter() {
    let formatter = DateFormatter.longDateAndShortTimeFormatter
    XCTAssertEqual(formatter.dateStyle, .long)
    XCTAssertEqual(formatter.timeStyle, .short)
  }
  
  func testCustomDateAndTimeFormatter() {
    let formatter = DateFormatter.customDateAndTimeFormatter
    XCTAssertEqual(formatter.dateStyle, .none)
    XCTAssertEqual(formatter.timeStyle, .none)
    XCTAssertEqual(formatter.dateFormat, "YY, MMM d, HH:mm:ss")
  }
  
  func testCustomDateFormatter() {
    let formatter = DateFormatter.customDateFormatter
    XCTAssertEqual(formatter.dateStyle, .none)
    XCTAssertEqual(formatter.timeStyle, .none)
    XCTAssertEqual(formatter.dateFormat, "yyyy-MM-dd")
  }
  
}
