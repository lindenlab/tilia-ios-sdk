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
    
    closeKeyboard(app: app)
    
    let doSmthButton = app.buttons["doSmthButton"]
    XCTAssert(doSmthButton.exists)
    doSmthButton.tap()
    
    let countryOfResidenceTextField = app.tables.cells.textFields["countryOfResidenceTextField"]
    XCTAssert(countryOfResidenceTextField.waitForExistence(timeout: 2))
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
    
    let useAddressForTaxTextField = app.tables.cells.textFields["useAddressForTaxTextField"]
    XCTAssert(useAddressForTaxTextField.exists)
    useAddressForTaxTextField.tap()
    
    let useAddressForTaxPicker = app.pickerWheels.firstMatch
    XCTAssert(useAddressForTaxPicker.exists)
    useAddressForTaxPicker.adjust(toPickerWheelValue: "Yes")
    useAddressForTaxTextField.typeText("\n")
    
    scrollUp(app: app, dy: -200)
    
    let continueButton = app.tables.buttons["continueButton"]
    XCTAssert(continueButton.exists)
    continueButton.tap()
    
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
    
    closeKeyboard(app: app)
    
    let doSmthButton = app.buttons["doSmthButton"]
    XCTAssert(doSmthButton.exists)
    doSmthButton.tap()
    
    let countryOfResidenceTextField = app.tables.cells.textFields["countryOfResidenceTextField"]
    XCTAssert(countryOfResidenceTextField.waitForExistence(timeout: 2))
    countryOfResidenceTextField.tap()
    
    let countryOfResidencePicker = app.pickerWheels.firstMatch
    XCTAssert(countryOfResidencePicker.exists)
    countryOfResidencePicker.adjust(toPickerWheelValue: "France")
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
    stateTextField.typeText("State\n")
    
    let postalCodeTextField = app.tables.cells.textFields["postalCodeTextField"]
    XCTAssert(postalCodeTextField.exists)
    postalCodeTextField.tap()
    postalCodeTextField.typeText("12324\n")
    
    let useAddressForTaxTextField = app.tables.cells.textFields["useAddressForTaxTextField"]
    XCTAssert(useAddressForTaxTextField.exists)
    useAddressForTaxTextField.tap()
    
    let useAddressForTaxPicker = app.pickerWheels.firstMatch
    XCTAssert(useAddressForTaxPicker.exists)
    useAddressForTaxPicker.adjust(toPickerWheelValue: "Yes")
    useAddressForTaxTextField.typeText("\n")
    
    scrollUp(app: app, dy: -200)
    
    let continueButton = app.tables.buttons["continueButton"]
    XCTAssert(continueButton.exists)
    continueButton.tap()
    
    wait(duration: 2)
    
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
    
    let frontSideDocumentImage = app.scrollViews.otherElements.images.firstMatch
    XCTAssert(frontSideDocumentImage.waitForExistence(timeout: 5))
    frontSideDocumentImage.tap()
    
    let backSideChooseButton = app.tables.cells.buttons["backSideChooseButton"]
    XCTAssert(backSideChooseButton.exists)
    backSideChooseButton.tap()
    
    let backSideDocumentImage = app.scrollViews.otherElements.images.firstMatch
    XCTAssert(backSideDocumentImage.waitForExistence(timeout: 5))
    backSideDocumentImage.tap()
    
    wait(duration: 2)
    scrollUp(app: app, dy: -300)
    
    let addDocumentButton = app.tables.cells.buttons["addDocumentButton"]
    XCTAssert(addDocumentButton.exists)
    addDocumentButton.tap()
    
    let selectDocumentFromGallery = app.buttons["Select from Gallery"]
    XCTAssert(selectDocumentFromGallery.exists)
    selectDocumentFromGallery.tap()
    
    let additionalDocumentImage = app.scrollViews.otherElements.images.firstMatch
    XCTAssert(additionalDocumentImage.waitForExistence(timeout: 5))
    additionalDocumentImage.tap()
    
    wait(duration: 2)
    scrollUp(app: app, dy: -300)
    
    let uploadButton = app.tables.buttons["uploadButton"]
    XCTAssert(uploadButton.waitForExistence(timeout: 2))
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
    
    closeKeyboard(app: app)
    
    let doSmthButton = app.buttons["doSmthButton"]
    XCTAssert(doSmthButton.exists)
    doSmthButton.tap()
    
    let countryOfResidenceTextField = app.tables.cells.textFields["countryOfResidenceTextField"]
    XCTAssert(countryOfResidenceTextField.waitForExistence(timeout: 2))
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
    
    let useAddressForTaxTextField = app.tables.cells.textFields["useAddressForTaxTextField"]
    XCTAssert(useAddressForTaxTextField.exists)
    useAddressForTaxTextField.tap()
    
    let useAddressForTaxPicker = app.pickerWheels.firstMatch
    XCTAssert(useAddressForTaxPicker.exists)
    useAddressForTaxPicker.adjust(toPickerWheelValue: "Yes")
    useAddressForTaxTextField.typeText("\n")
    
    scrollUp(app: app, dy: -200)
    
    let continueButton = app.tables.buttons["continueButton"]
    XCTAssert(continueButton.exists)
    continueButton.tap()
    
    let doneButton = app.tables.buttons["closeButton"]
    XCTAssert(doneButton.waitForExistence(timeout: 2))
    doneButton.tap()
    
    let backButton = app.navigationBars["KYC flow"].buttons["Demo App"]
    XCTAssert(backButton.exists)
    backButton.tap()
  }
  
}
