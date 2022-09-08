//
//  TransactionDetailsFlowUITests.swift
//  TiliaSDKUITests
//
//  Created by Serhii.Petrishenko on 07.09.2022.
//

import XCTest

final class TransactionDetailsFlowUITests: XCTestCase {
  
  override func setUpWithError() throws {
    continueAfterFailure = false
  }
  
  func testTransactionDetails() {
    let app = XCUIApplication()
    app.launch()
        
    let useMocksSwitch = app.switches["useMocksSwitch"]
    XCTAssert(useMocksSwitch.exists)
    useMocksSwitch.tap()
    
    let cell = app.tables.staticTexts["Transaction Details flow"]
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
    
    let _ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 2)
    let visibleCells = app.tables.cells
    let startElement = visibleCells.element(boundBy: (visibleCells.count - 1) / 2)
    scrollUp(app: app, dy: -400, startElement: startElement)
    
    let emailReceiptButton = app.buttons["emailReceiptButton"]
    XCTAssert(emailReceiptButton.waitForExistence(timeout: 2))
    emailReceiptButton.tap()
    
    let emailTextField = app.textFields["emailTextField"]
    XCTAssert(emailTextField.waitForExistence(timeout: 2))
    emailTextField.tap()
    emailTextField.typeText("test@gmail.com")
    
    let sendButton = app.buttons["sendButton"]
    XCTAssert(sendButton.exists)
    sendButton.tap()
    
    let closeButton = app.tables.buttons["closeButton"]
    XCTAssert(closeButton.waitForExistence(timeout: 2))
    closeButton.tap()
    
    let backButton = app.navigationBars["Transaction Details flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
  }
  
}
