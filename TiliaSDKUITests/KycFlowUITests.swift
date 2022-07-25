//
//  KycFlowUITests.swift
//  TiliaSDKUITests
//
//  Created by Serhii.Petrishenko on 25.07.2022.
//

import XCTest

final class KycFlowUITests: XCTestCase {
  
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testKyc() {
    let app = XCUIApplication()
    app.launch()
        
    let useMocksSwitch = app.switches["useMocksSwitch"]
    XCTAssert(useMocksSwitch.exists)
    useMocksSwitch.tap()
    
    let cell = app.tables.staticTexts["Checkout flow"]
    XCTAssert(cell.exists)
    cell.tap()
  }
  
}
