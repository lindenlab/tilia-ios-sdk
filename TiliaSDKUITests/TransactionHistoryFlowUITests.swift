//
//  TransactionHistoryFlowUITests.swift
//  TiliaSDKUITests
//
//  Created by Serhii.Petrishenko on 17.10.2022.
//

import XCTest

final class TransactionHistoryFlowUITests: XCTestCase {
  
  override func setUpWithError() throws {
    continueAfterFailure = false
  }
  
  func testTransactionHistory() {
    let app = XCUIApplication()
    app.launch()
        
    let useMocksSwitch = app.switches["useMocksSwitch"]
    XCTAssert(useMocksSwitch.exists)
    useMocksSwitch.tap()
    
    let cell = app.tables.staticTexts["Transaction History flow"]
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
    
    let transactionCell = app.tables.cells.firstMatch
    XCTAssert(transactionCell.waitForExistence(timeout: 2))
    transactionCell.tap()
    
    scrollUp(app: app, dy: -400)
    
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
    
    let closeTransactionDetailsButton = app.tables.buttons["closeButton"]
    XCTAssert(closeTransactionDetailsButton.waitForExistence(timeout: 2))
    closeTransactionDetailsButton.tap()
    
    let closeButton = app.buttons["closeButton"]
    XCTAssert(closeButton.waitForExistence(timeout: 2))
    closeButton.tap()
    
    let backButton = app.navigationBars["Transaction History flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
  }
  
}
