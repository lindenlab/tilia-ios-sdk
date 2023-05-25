//
//  PaymentSelectionFlowUITests.swift
//  TiliaSDKUITests
//
//  Created by Serhii.Petrishenko on 25.05.2023.
//

import XCTest

final class PaymentSelectionFlowUITests: XCTestCase {
  
  override func setUpWithError() throws {
    continueAfterFailure = false
  }
  
  func testWithOnePaymentMethodSelection() {
    let app = XCUIApplication()
    app.launch()
        
    let useMocksSwitch = app.switches["useMocksSwitch"]
    XCTAssert(useMocksSwitch.exists)
    useMocksSwitch.tap()
    
    let cell = app.tables.staticTexts["Payment Selection flow"]
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
    
    let acceptSwitch = app.switches["acceptSwitch"]
    XCTAssert(acceptSwitch.waitForExistence(timeout: 2))
    acceptSwitch.tap()
    
    let acceptButton = app.buttons["acceptButton"]
    XCTAssert(acceptButton.waitForExistence(timeout: 2))
    acceptButton.tap()
    
    let choosePaymentMethodButton = app.tables.cells["paymentMethodRadioCell"].buttons["choosePaymentMethodButton"].firstMatch
    XCTAssert(choosePaymentMethodButton.waitForExistence(timeout: 2))
    choosePaymentMethodButton.tap()
    
    let payButton = app.tables.otherElements.buttons["payButton"]
    XCTAssert(payButton.exists)
    payButton.tap()

    let backButton = app.navigationBars["Payment Selection flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
  }
  
  func testWithTwoPaymentMethodsSelection() {
    let app = XCUIApplication()
    app.launch()
        
    let useMocksSwitch = app.switches["useMocksSwitch"]
    XCTAssert(useMocksSwitch.exists)
    useMocksSwitch.tap()
    
    let cell = app.tables.staticTexts["Payment Selection flow"]
    XCTAssert(cell.exists)
    cell.tap()
    
    let accessTokenTextField = app.textFields["accessTokenTextField"]
    XCTAssert(accessTokenTextField.exists)
    accessTokenTextField.tap()
    accessTokenTextField.typeText(UUID().uuidString)
    
    let amountTextField = app.textFields["amountTextField"]
    XCTAssert(amountTextField.exists)
    amountTextField.tap()
    amountTextField.typeText("1000000")
    
    let currencyTextField = app.textFields["currencyTextField"]
    XCTAssert(currencyTextField.exists)
    currencyTextField.tap()
    currencyTextField.typeText("USD")
    
    closeKeyboard(app: app)
    
    let doSmthButton = app.buttons["doSmthButton"]
    XCTAssert(doSmthButton.exists)
    doSmthButton.tap()
    
    let acceptSwitch = app.switches["acceptSwitch"]
    XCTAssert(acceptSwitch.waitForExistence(timeout: 2))
    acceptSwitch.tap()
    
    let acceptButton = app.buttons["acceptButton"]
    XCTAssert(acceptButton.waitForExistence(timeout: 2))
    acceptButton.tap()
    
    let choosePaymentMethodSwithch = app.tables.cells["paymentMethodSwitchCell"].switches["selectPaymentMethodSwitch"].firstMatch
    XCTAssert(choosePaymentMethodSwithch.waitForExistence(timeout: 2))
    choosePaymentMethodSwithch.tap()
    
    let choosePaymentMethodButton = app.tables.cells["paymentMethodRadioCell"].buttons["choosePaymentMethodButton"].firstMatch
    XCTAssert(choosePaymentMethodButton.exists)
    choosePaymentMethodButton.tap()
    
    let payButton = app.tables.otherElements.buttons["payButton"]
    XCTAssert(payButton.exists)
    payButton.tap()

    let backButton = app.navigationBars["Payment Selection flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
  }
  
  func testPaymentSelectionWithAddingCard() {
    let app = XCUIApplication()
    app.launch()
        
    let useMocksSwitch = app.switches["useMocksSwitch"]
    XCTAssert(useMocksSwitch.exists)
    useMocksSwitch.tap()
    
    let cell = app.tables.staticTexts["Payment Selection flow"]
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
    
    let acceptSwitch = app.switches["acceptSwitch"]
    XCTAssert(acceptSwitch.waitForExistence(timeout: 2))
    acceptSwitch.tap()
    
    let acceptButton = app.buttons["acceptButton"]
    XCTAssert(acceptButton.waitForExistence(timeout: 2))
    acceptButton.tap()
    
    let addCreditCardButton = app.tables.otherElements.buttons["addCreditCardButton"]
    XCTAssert(addCreditCardButton.waitForExistence(timeout: 2))
    addCreditCardButton.tap()
    
    let openBrowserButton = app.buttons["openBrowserButton"]
    XCTAssert(openBrowserButton.waitForExistence(timeout: 2))
    openBrowserButton.tap()
    
    let closeSafariViewButton = app.buttons["Done"]
    XCTAssert(closeSafariViewButton.waitForExistence(timeout: 4))
    closeSafariViewButton.tapUnhittable()
    
    let closeAddCreditCardFlowButton = app.buttons["doneButton"]
    XCTAssert(closeAddCreditCardFlowButton.waitForExistence(timeout: 2))
    closeAddCreditCardFlowButton.tap()
      
    let choosePaymentMethodButton = app.tables.cells["paymentMethodRadioCell"].buttons["choosePaymentMethodButton"].firstMatch
    XCTAssert(choosePaymentMethodButton.waitForExistence(timeout: 2))
    choosePaymentMethodButton.tap()

    let payButton = app.tables.otherElements.buttons["payButton"]
    XCTAssert(payButton.exists)
    payButton.tap()

    let backButton = app.navigationBars["Payment Selection flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
  }
  
}
