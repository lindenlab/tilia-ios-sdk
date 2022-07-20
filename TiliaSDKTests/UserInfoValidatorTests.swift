//
//  UserInfoValidatorTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 20.07.2022.
//

import XCTest
@testable import TiliaSDK

final class UserInfoValidatorTests: XCTestCase {
  
  func testSuccessUserInfoLocationValidator() {
    var model = UserInfoModel()
    model.countryOfResidence = .init(name: "USA", code: "US")
    let isFilled = UserInfoLocationValidator().isFilled(for: model)
    XCTAssertTrue(isFilled)
  }
  
  func testFailureUserInfoLocationValidator() {
    let model = UserInfoModel()
    let isFilled = UserInfoLocationValidator().isFilled(for: model)
    XCTAssertFalse(isFilled)
  }
  
  func testSuccessUserInfoPersonalValidator() {
    var model = UserInfoModel()
    model.fullName = .init(first: "First", middle: "Middle", last: "Last")
    model.dateOfBirth = Date()
    let isFilled = UserInfoPersonalValidator().isFilled(for: model)
    XCTAssertTrue(isFilled)
  }
  
  func testFailureUserInfoPersonalValidator() {
    let model = UserInfoModel()
    let isFilled = UserInfoPersonalValidator().isFilled(for: model)
    XCTAssertFalse(isFilled)
  }
  
  func testSuccessUserInfoTaxValidator() {
    var model = UserInfoModel()
    model.tax = .init(ssn: "1232131", signature: "Signature")
    let isFilled = UserInfoTaxValidator().isFilled(for: model)
    XCTAssertTrue(isFilled)
  }
  
  func testFailureUserInfoTaxValidator() {
    let model = UserInfoModel()
    let isFilled = UserInfoTaxValidator().isFilled(for: model)
    XCTAssertFalse(isFilled)
  }
  
  func testSuccessUserInfoContactValidator() {
    var model = UserInfoModel()
    model.address = .init(street: "Street",
                          apartment: "Apartment",
                          city: "City",
                          region: .init(name: "Name", code: "Code"),
                          postalCode: "12321321")
    let isFilled = UserInfoContactValidator().isFilled(for: model)
    XCTAssertTrue(isFilled)
  }
  
  func testFailureUserInfoContactValidator() {
    let model = UserInfoModel()
    let isFilled = UserInfoContactValidator().isFilled(for: model)
    XCTAssertFalse(isFilled)
  }
  
}
