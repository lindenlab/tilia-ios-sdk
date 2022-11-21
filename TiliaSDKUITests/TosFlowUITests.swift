//
//  TosFlowUITests.swift
//  TiliaSDKUITests
//
//  Created by Serhii.Petrishenko on 12.04.2022.
//

import XCTest
@testable import TiliaSDK

final class TosFlowUITests: XCTestCase {
  
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
    
    closeKeyboard(app: app)
    
    let doSmthButton = app.buttons["doSmthButton"]
    XCTAssert(doSmthButton.exists)
    doSmthButton.tap()
    
    let tosLink = app.textViews.links["Terms of Service"]
    XCTAssert(tosLink.waitForExistence(timeout: 2))
    tosLink.tap()
    
    let tosContentCloseButton = app.buttons["closeButton"]
    XCTAssert(tosContentCloseButton.waitForExistence(timeout: 2))
    tosContentCloseButton.tap()
    
    let acceptSwitch = app.switches["acceptSwitch"]
    XCTAssert(acceptSwitch.waitForExistence(timeout: 2))
    acceptSwitch.tap()
    
    let acceptButton = app.buttons["acceptButton"]
    XCTAssert(acceptButton.exists)
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
    
    closeKeyboard(app: app)
    
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
