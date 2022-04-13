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
  
  func testSuccessTos() throws {
    let app = XCUIApplication()
    app.launch()
    
    let cell = app.tables.staticTexts["TOS flow"]
    XCTAssert(cell.isHittable)
    cell.tap()
    
    let accessTokenTextField = app.textFields["accessTokenTextField"]
    XCTAssert(accessTokenTextField.isHittable)
    accessTokenTextField.tap()
    accessTokenTextField.typeText(UUID().uuidString)
    
    app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
    
    let doSmthButton = app.buttons["doSmthButton"]
    XCTAssert(doSmthButton.isHittable)
    doSmthButton.tap()
    
    let cancelButton = app.buttons["cancelButton"]
    XCTAssert(cancelButton.isHittable)
    cancelButton.tap()
    
    doSmthButton.tap()
    
    let acceptSwitch = app.switches["acceptSwitch"]
    XCTAssert(acceptSwitch.isHittable)
    acceptSwitch.tap()
    
    let acceptButton = app.buttons["acceptButton"]
    XCTAssert(acceptButton.isHittable)
    acceptButton.tap()
    
    let backButton = app.navigationBars["TOS flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
  }
  
  func testErrorTos() throws {
    let app = XCUIApplication()
    app.launch()
    
    let cell = app.tables.staticTexts["TOS flow"]
    XCTAssert(cell.isHittable)
    cell.tap()
    
    let accessTokenTextField = app.textFields["accessTokenTextField"]
    XCTAssert(accessTokenTextField.isHittable)
    accessTokenTextField.tap()
    accessTokenTextField.typeText("")
    
    app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
    
    let doSmthButton = app.buttons["doSmthButton"]
    XCTAssert(doSmthButton.isHittable)
    doSmthButton.tap()
    
    sleep(1)
    let backButton = app.navigationBars["TOS flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
    
  }
  
}
