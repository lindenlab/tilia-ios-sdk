//
//  CheckoutFlowUITests.swift
//  TiliaSDKUITests
//
//  Created by Serhii.Petrishenko on 12.04.2022.
//

import XCTest

class CheckoutFlowUITests: XCTestCase {
  
  override func setUpWithError() throws {
    continueAfterFailure = false
  }
  
  func testCheckout() {
    let app = XCUIApplication()
    app.launch()
        
    let useMocksSwitch = app.switches["useMocksSwitch"]
    XCTAssert(useMocksSwitch.exists)
    useMocksSwitch.tap()
    
    let cell = app.tables.staticTexts["Checkout flow"]
    XCTAssert(cell.exists)
    cell.tap()
    
    let accessTokenTextField = app.textFields["accessTokenTextField"]
    XCTAssert(accessTokenTextField.exists)
    accessTokenTextField.tap()
    accessTokenTextField.typeText(UUID().uuidString)
    
    let invoiceIdTextField = app.textFields["invoiceIdTextField"]
    XCTAssert(invoiceIdTextField.exists)
    invoiceIdTextField.tap()
    invoiceIdTextField.typeText(UUID().uuidString)
    
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
    
    let payButton = app.tables.otherElements.buttons["primaryButton"]
    XCTAssert(payButton.waitForExistence(timeout: 3))
    payButton.tap()
    
    let doneButton = app.tables.otherElements.buttons["nonPrimaryButton"]
    XCTAssert(doneButton.waitForExistence(timeout: 2))
    doneButton.tap()

    let backButton = app.navigationBars["Checkout flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
  }
  
  func testCancelCheckout() {
    let app = XCUIApplication()
    app.launch()
        
    let useMocksSwitch = app.switches["useMocksSwitch"]
    XCTAssert(useMocksSwitch.exists)
    useMocksSwitch.tap()
    
    let cell = app.tables.staticTexts["Checkout flow"]
    XCTAssert(cell.exists)
    cell.tap()
    
    let accessTokenTextField = app.textFields["accessTokenTextField"]
    XCTAssert(accessTokenTextField.exists)
    accessTokenTextField.tap()
    accessTokenTextField.typeText(UUID().uuidString)
    
    let invoiceIdTextField = app.textFields["invoiceIdTextField"]
    XCTAssert(invoiceIdTextField.exists)
    invoiceIdTextField.tap()
    invoiceIdTextField.typeText(UUID().uuidString)
    
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
    
    let cancelButton = app.tables.otherElements.buttons["nonPrimaryButton"]
    XCTAssert(cancelButton.waitForExistence(timeout: 3))
    cancelButton.tap()

    let backButton = app.navigationBars["Checkout flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
  }
  
  func testCancelCheckoutFromTos() {
    let app = XCUIApplication()
    app.launch()
        
    let useMocksSwitch = app.switches["useMocksSwitch"]
    XCTAssert(useMocksSwitch.exists)
    useMocksSwitch.tap()
    
    let cell = app.tables.staticTexts["Checkout flow"]
    XCTAssert(cell.exists)
    cell.tap()
    
    let accessTokenTextField = app.textFields["accessTokenTextField"]
    XCTAssert(accessTokenTextField.exists)
    accessTokenTextField.tap()
    accessTokenTextField.typeText(UUID().uuidString)
    
    let invoiceIdTextField = app.textFields["invoiceIdTextField"]
    XCTAssert(invoiceIdTextField.exists)
    invoiceIdTextField.tap()
    invoiceIdTextField.typeText(UUID().uuidString)
    
    app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
    
    let doSmthButton = app.buttons["doSmthButton"]
    XCTAssert(doSmthButton.exists)
    doSmthButton.tap()
    
    let cancelButton = app.buttons["cancelButton"]
    XCTAssert(cancelButton.waitForExistence(timeout: 2))
    cancelButton.tap()

    let backButton = app.navigationBars["Checkout flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
  }
  
}
