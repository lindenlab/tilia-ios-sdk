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

  func testKycForUsResident() {
    let app = XCUIApplication()
    app.launch()
        
    let useMocksSwitch = app.switches["useMocksSwitch"]
    XCTAssert(useMocksSwitch.exists)
    useMocksSwitch.tap()
    
    let cell = app.tables.staticTexts["KYC flow"]
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
    
    let locationHeader = app.tables.otherElements["locationHeader"]
    XCTAssert(locationHeader.exists)
    locationHeader.tap()
    
    let countryOfResidenceTextField = app.tables.cells.textFields["countryOfResidenceTextField"]
    XCTAssert(countryOfResidenceTextField.exists)
    countryOfResidenceTextField.tap()
    countryOfResidenceTextField.typeText("\n")
    
    let locationNextButton = app.tables.cells.buttons["nextButton"]
    XCTAssert(locationNextButton.exists)
    locationNextButton.tap()

    let firstNameTextField = app.tables.cells.textFields["firstNameTextField"]
    XCTAssert(firstNameTextField.exists)
    firstNameTextField.tap()
    firstNameTextField.typeText("First\n")
    
    let middleNameTextField = app.tables.cells.textFields["middleNameTextField"]
    XCTAssert(middleNameTextField.exists)
    middleNameTextField.tap()
    middleNameTextField.typeText("Middle\n")
    
    let lastNameTextField = app.tables.cells.textFields["lastNameTextField"]
    XCTAssert(lastNameTextField.exists)
    lastNameTextField.tap()
    lastNameTextField.typeText("Last\n")
    
    let dateOfBirthTextField = app.tables.cells.textFields["dateOfBirthTextField"]
    XCTAssert(dateOfBirthTextField.exists)
    dateOfBirthTextField.tap()
    dateOfBirthTextField.typeText("\n")
    
    let personalNextButton = app.tables.cells.buttons["nextButton"]
    XCTAssert(personalNextButton.exists)
    personalNextButton.tap()
    
    let ssnTextField = app.tables.cells.textFields["ssnTextField"]
    XCTAssert(ssnTextField.exists)
    ssnTextField.tap()
    ssnTextField.typeText("123456789\n")
    
    let signatureTextField = app.tables.cells.textFields["signatureTextField"]
    XCTAssert(signatureTextField.exists)
    signatureTextField.tap()
    signatureTextField.typeText("Signature\n")
    
    let taxInfoNextButton = app.tables.cells.buttons["nextButton"]
    XCTAssert(taxInfoNextButton.exists)
    taxInfoNextButton.tap()
    
    let streetTextField = app.tables.cells.textFields["streetTextField"]
    XCTAssert(streetTextField.exists)
    streetTextField.tap()
    streetTextField.typeText("Street\n")
    
    let apartmentTextField = app.tables.cells.textFields["apartmentTextField"]
    XCTAssert(apartmentTextField.exists)
    apartmentTextField.tap()
    apartmentTextField.typeText("12, 32b\n")
    
    let cityTextField = app.tables.cells.textFields["cityTextField"]
    XCTAssert(cityTextField.exists)
    cityTextField.tap()
    cityTextField.typeText("City\n")
    
    let stateTextField = app.tables.cells.textFields["stateTextField"]
    XCTAssert(stateTextField.exists)
    stateTextField.tap()
    stateTextField.typeText("\n")
    
    let postalCodeTextField = app.tables.cells.textFields["postalCodeTextField"]
    XCTAssert(postalCodeTextField.exists)
    postalCodeTextField.tap()
    postalCodeTextField.typeText("12324\n")
    
    let useAddressFor1099TextField = app.tables.cells.textFields["useAddressFor1099TextField"]
    XCTAssert(useAddressFor1099TextField.exists)
    useAddressFor1099TextField.tap()
    useAddressFor1099TextField.typeText("\n")
    
    scrollUp(app: app, dy: -200)
    
    let continueButton = app.tables.buttons["continueButton"]
    XCTAssert(continueButton.exists)
    continueButton.tap()
    
    let documentTextField = app.tables.cells.textFields["documentTextField"]
    XCTAssert(documentTextField.exists)
    documentTextField.tap()
    documentTextField.typeText("\n")
    
    let frontSideChooseButton = app.tables.cells.buttons["frontSideChooseButton"]
    XCTAssert(frontSideChooseButton.exists)
    frontSideChooseButton.tap()
    
    let frontSideDocumentImage = app.scrollViews.otherElements.images["Photo, March 30, 2018, 10:14 PM"]
    XCTAssert(frontSideDocumentImage.waitForExistence(timeout: 10))
    frontSideDocumentImage.tap()
    
    let isAddressOnDocumentTextField = app.tables.cells.textFields["isAddressOnDocumentTextField"]
    XCTAssert(isAddressOnDocumentTextField.exists)
    isAddressOnDocumentTextField.tap()
    isAddressOnDocumentTextField.typeText("\n")
    
    scrollUp(app: app, dy: -200)
    
    let uploadButton = app.tables.buttons["uploadButton"]
    XCTAssert(uploadButton.exists)
    uploadButton.tap()
    
    let doneButton = app.tables.buttons["doneButton"]
    XCTAssert(doneButton.waitForExistence(timeout: 8))
    doneButton.tap()
    
    let backButton = app.navigationBars["KYC flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
  }
  
  func testKycForNonUsResident() {
    let app = XCUIApplication()
    app.launch()
        
    let useMocksSwitch = app.switches["useMocksSwitch"]
    XCTAssert(useMocksSwitch.exists)
    useMocksSwitch.tap()
    
    let cell = app.tables.staticTexts["KYC flow"]
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
    
    let locationHeader = app.tables.otherElements["locationHeader"]
    XCTAssert(locationHeader.exists)
    locationHeader.tap()
    
    let countryOfResidenceTextField = app.tables.cells.textFields["countryOfResidenceTextField"]
    XCTAssert(countryOfResidenceTextField.exists)
    countryOfResidenceTextField.tap()
    
    let countryOfResidencePicker = app.pickerWheels.firstMatch
    XCTAssert(countryOfResidencePicker.exists)
    countryOfResidencePicker.adjust(toPickerWheelValue: "Canada")
    countryOfResidenceTextField.typeText("\n")
    
    let locationNextButton = app.tables.cells.buttons["nextButton"]
    XCTAssert(locationNextButton.exists)
    locationNextButton.tap()

    let firstNameTextField = app.tables.cells.textFields["firstNameTextField"]
    XCTAssert(firstNameTextField.exists)
    firstNameTextField.tap()
    firstNameTextField.typeText("First\n")
    
    let middleNameTextField = app.tables.cells.textFields["middleNameTextField"]
    XCTAssert(middleNameTextField.exists)
    middleNameTextField.tap()
    middleNameTextField.typeText("Middle\n")
    
    let lastNameTextField = app.tables.cells.textFields["lastNameTextField"]
    XCTAssert(lastNameTextField.exists)
    lastNameTextField.tap()
    lastNameTextField.typeText("Last\n")
    
    let dateOfBirthTextField = app.tables.cells.textFields["dateOfBirthTextField"]
    XCTAssert(dateOfBirthTextField.exists)
    dateOfBirthTextField.tap()
    dateOfBirthTextField.typeText("\n")
    
    let personalNextButton = app.tables.cells.buttons["nextButton"]
    XCTAssert(personalNextButton.exists)
    personalNextButton.tap()
    
    let streetTextField = app.tables.cells.textFields["streetTextField"]
    XCTAssert(streetTextField.exists)
    streetTextField.tap()
    streetTextField.typeText("Street\n")
    
    let apartmentTextField = app.tables.cells.textFields["apartmentTextField"]
    XCTAssert(apartmentTextField.exists)
    apartmentTextField.tap()
    apartmentTextField.typeText("12, 32b\n")
    
    let cityTextField = app.tables.cells.textFields["cityTextField"]
    XCTAssert(cityTextField.exists)
    cityTextField.tap()
    cityTextField.typeText("City\n")
    
    let stateTextField = app.tables.cells.textFields["stateTextField"]
    XCTAssert(stateTextField.exists)
    stateTextField.tap()
    stateTextField.typeText("\n")
    
    let postalCodeTextField = app.tables.cells.textFields["postalCodeTextField"]
    XCTAssert(postalCodeTextField.exists)
    postalCodeTextField.tap()
    postalCodeTextField.typeText("12324\n")
    
    scrollUp(app: app, dy: -200)
    
    let continueButton = app.tables.buttons["continueButton"]
    XCTAssert(continueButton.exists)
    continueButton.tap()
    
    let documentTextField = app.tables.cells.textFields["documentTextField"]
    XCTAssert(documentTextField.exists)
    documentTextField.tap()
    
    let documentPicker = app.pickerWheels.firstMatch
    XCTAssert(documentPicker.exists)
    documentPicker.adjust(toPickerWheelValue: "Driver's license")
    documentTextField.typeText("\n")
    
    let frontSideChooseButton = app.tables.cells.buttons["frontSideChooseButton"]
    XCTAssert(frontSideChooseButton.exists)
    frontSideChooseButton.tap()
    
    let frontSideDocumentImage = app.scrollViews.otherElements.images["Photo, March 30, 2018, 10:14 PM"]
    XCTAssert(frontSideDocumentImage.waitForExistence(timeout: 5))
    frontSideDocumentImage.tap()
    
    let backSideChooseButton = app.tables.cells.buttons["backSideChooseButton"]
    XCTAssert(backSideChooseButton.exists)
    backSideChooseButton.tap()
    
    let backSideDocumentImage = app.scrollViews.otherElements.images["Photo, March 30, 2018, 10:14 PM"]
    XCTAssert(backSideDocumentImage.waitForExistence(timeout: 5))
    backSideDocumentImage.tap()
    
    sleep(1)
    scrollUp(app: app, dy: -400)
    
    let addDocumentButton = app.tables.cells.buttons["addDocumentButton"]
    XCTAssert(addDocumentButton.exists)
    addDocumentButton.tap()
    
    let selectDocumentFromGallery = app.sheets.buttons["Select from Gallery"]
    XCTAssert(selectDocumentFromGallery.exists)
    selectDocumentFromGallery.tap()
    
    let additionalDocumentImage = app.scrollViews.otherElements.images["Photo, March 30, 2018, 10:14 PM"]
    XCTAssert(additionalDocumentImage.waitForExistence(timeout: 5))
    additionalDocumentImage.tap()
    
    sleep(1)
    scrollUp(app: app, dy: -200)
    
    let uploadButton = app.tables.buttons["uploadButton"]
    XCTAssert(uploadButton.exists)
    uploadButton.tap()
    
    let doneButton = app.tables.buttons["doneButton"]
    XCTAssert(doneButton.waitForExistence(timeout: 8))
    doneButton.tap()
    
    let backButton = app.navigationBars["KYC flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
  }
  
  func testCancelWaitingKycResult() {
    let app = XCUIApplication()
    app.launch()
        
    let useMocksSwitch = app.switches["useMocksSwitch"]
    XCTAssert(useMocksSwitch.exists)
    useMocksSwitch.tap()
    
    let cell = app.tables.staticTexts["KYC flow"]
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
    
    let locationHeader = app.tables.otherElements["locationHeader"]
    XCTAssert(locationHeader.exists)
    locationHeader.tap()
    
    let countryOfResidenceTextField = app.tables.cells.textFields["countryOfResidenceTextField"]
    XCTAssert(countryOfResidenceTextField.exists)
    countryOfResidenceTextField.tap()
    countryOfResidenceTextField.typeText("\n")
    
    let locationNextButton = app.tables.cells.buttons["nextButton"]
    XCTAssert(locationNextButton.exists)
    locationNextButton.tap()

    let firstNameTextField = app.tables.cells.textFields["firstNameTextField"]
    XCTAssert(firstNameTextField.exists)
    firstNameTextField.tap()
    firstNameTextField.typeText("First\n")
    
    let middleNameTextField = app.tables.cells.textFields["middleNameTextField"]
    XCTAssert(middleNameTextField.exists)
    middleNameTextField.tap()
    middleNameTextField.typeText("Middle\n")
    
    let lastNameTextField = app.tables.cells.textFields["lastNameTextField"]
    XCTAssert(lastNameTextField.exists)
    lastNameTextField.tap()
    lastNameTextField.typeText("Last\n")
    
    let dateOfBirthTextField = app.tables.cells.textFields["dateOfBirthTextField"]
    XCTAssert(dateOfBirthTextField.exists)
    dateOfBirthTextField.tap()
    dateOfBirthTextField.typeText("\n")
    
    let personalNextButton = app.tables.cells.buttons["nextButton"]
    XCTAssert(personalNextButton.exists)
    personalNextButton.tap()
    
    let ssnTextField = app.tables.cells.textFields["ssnTextField"]
    XCTAssert(ssnTextField.exists)
    ssnTextField.tap()
    ssnTextField.typeText("123456789\n")
    
    let signatureTextField = app.tables.cells.textFields["signatureTextField"]
    XCTAssert(signatureTextField.exists)
    signatureTextField.tap()
    signatureTextField.typeText("Signature\n")
    
    let taxInfoNextButton = app.tables.cells.buttons["nextButton"]
    XCTAssert(taxInfoNextButton.exists)
    taxInfoNextButton.tap()
    
    let streetTextField = app.tables.cells.textFields["streetTextField"]
    XCTAssert(streetTextField.exists)
    streetTextField.tap()
    streetTextField.typeText("Street\n")
    
    let apartmentTextField = app.tables.cells.textFields["apartmentTextField"]
    XCTAssert(apartmentTextField.exists)
    apartmentTextField.tap()
    apartmentTextField.typeText("12, 32b\n")
    
    let cityTextField = app.tables.cells.textFields["cityTextField"]
    XCTAssert(cityTextField.exists)
    cityTextField.tap()
    cityTextField.typeText("City\n")
    
    let stateTextField = app.tables.cells.textFields["stateTextField"]
    XCTAssert(stateTextField.exists)
    stateTextField.tap()
    stateTextField.typeText("\n")
    
    let postalCodeTextField = app.tables.cells.textFields["postalCodeTextField"]
    XCTAssert(postalCodeTextField.exists)
    postalCodeTextField.tap()
    postalCodeTextField.typeText("12324\n")
    
    let useAddressFor1099TextField = app.tables.cells.textFields["useAddressFor1099TextField"]
    XCTAssert(useAddressFor1099TextField.exists)
    useAddressFor1099TextField.tap()
    useAddressFor1099TextField.typeText("\n")
    
    scrollUp(app: app, dy: -200)
    
    let continueButton = app.tables.buttons["continueButton"]
    XCTAssert(continueButton.exists)
    continueButton.tap()
    
    let documentTextField = app.tables.cells.textFields["documentTextField"]
    XCTAssert(documentTextField.exists)
    documentTextField.tap()
    documentTextField.typeText("\n")
    
    let frontSideChooseButton = app.tables.cells.buttons["frontSideChooseButton"]
    XCTAssert(frontSideChooseButton.exists)
    frontSideChooseButton.tap()
    
    let frontSideDocumentImage = app.scrollViews.otherElements.images["Photo, March 30, 2018, 10:14 PM"]
    XCTAssert(frontSideDocumentImage.waitForExistence(timeout: 5))
    frontSideDocumentImage.tap()
    
    let isAddressOnDocumentTextField = app.tables.cells.textFields["isAddressOnDocumentTextField"]
    XCTAssert(isAddressOnDocumentTextField.exists)
    isAddressOnDocumentTextField.tap()
    isAddressOnDocumentTextField.typeText("\n")
    
    scrollUp(app: app, dy: -200)
    
    let uploadButton = app.tables.buttons["uploadButton"]
    XCTAssert(uploadButton.exists)
    uploadButton.tap()
    
    let doneButton = app.tables.buttons["closeButton"]
    XCTAssert(doneButton.waitForExistence(timeout: 2))
    doneButton.tap()
    
    let backButton = app.navigationBars["KYC flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
  }
  
}

private extension KycFlowUITests {
  
  func scrollUp(app: XCUIApplication, dy: CGFloat) {
    let visibleCells = app.tables.cells
    let startCoordinate = visibleCells.element(boundBy: visibleCells.count - 1).coordinate(withNormalizedOffset: .zero)
    let endCoordinate = startCoordinate.withOffset(CGVector(dx: 0.0, dy: dy))
    startCoordinate.press(forDuration: 0.1, thenDragTo: endCoordinate)
  }
  
}
