//
//  TosFlowUITests.swift
//  TiliaSDKUITests
//
//  Created by Serhii.Petrishenko on 12.04.2022.
//

import XCTest
@testable import TiliaSDK

class TosFlowUITests: XCTestCase {
  
  override func setUpWithError() throws {
    continueAfterFailure = false
  }
  
  func testAcceptTos() {
    let app = XCUIApplication()
    app.launch()
        
    let useMocksSwitch = app.switches["useMocksSwitch"]
    XCTAssert(useMocksSwitch.exists)
    useMocksSwitch.tap()
    
    let cell = app.tables.staticTexts["TOS flow"]
    XCTAssert(cell.exists)
    cell.tap()
    
    let accessTokenTextField = app.textFields["accessTokenTextField"]
    XCTAssert(accessTokenTextField.exists)
    accessTokenTextField.tap()
    accessTokenTextField.typeText(UUID().uuidString)
    
    app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
    
    let doSmthButton = app.buttons["doSmthButton"]
    XCTAssert(doSmthButton.exists)
    doSmthButton.tap()
    
    let acceptSwitch = app.switches["acceptSwitch"]
    XCTAssert(acceptSwitch.waitForExistence(timeout: 2))
    acceptSwitch.tap()
    
    let acceptButton = app.buttons["acceptButton"]
    XCTAssert(acceptButton.waitForExistence(timeout: 2))
    acceptButton.tap()
    
    let backButton = app.navigationBars["TOS flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
  }
  
  func testCancelTos() {
    let app = XCUIApplication()
    app.launch()
        
    let useMocksSwitch = app.switches["useMocksSwitch"]
    XCTAssert(useMocksSwitch.exists)
    useMocksSwitch.tap()
    
    let cell = app.tables.staticTexts["TOS flow"]
    XCTAssert(cell.exists)
    cell.tap()
    
    let accessTokenTextField = app.textFields["accessTokenTextField"]
    XCTAssert(accessTokenTextField.exists)
    accessTokenTextField.tap()
    accessTokenTextField.typeText(UUID().uuidString)
    
    app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
    
    let doSmthButton = app.buttons["doSmthButton"]
    XCTAssert(doSmthButton.exists)
    doSmthButton.tap()
    
    let cancelButton = app.buttons["cancelButton"]
    XCTAssert(cancelButton.waitForExistence(timeout: 2))
    cancelButton.tap()
    
    let backButton = app.navigationBars["TOS flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
  }
  
}
