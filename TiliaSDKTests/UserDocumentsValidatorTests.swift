//
//  UserDocumentsValidatorTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 20.07.2022.
//

import XCTest
@testable import TiliaSDK

final class UserDocumentsValidatorTests: XCTestCase {
  
  func testSuccessOnlyOneDocumentSide() {
    var model = UserDocumentsModel()
    model.document = .passport
    model.frontImage = .init(image: .init(), data: .init(), type: .image)
    model.documentCountry = .init(name: "USA", code: "US")
    model.additionalDocuments = [.init(image: .init(), data: .init(), type: .pdf)]
    let isFilled = UserDocumentsValidator.isFilled(for: model)
    XCTAssertTrue(isFilled)
  }
  
  func testSuccessBothDocumentSides() {
    var model = UserDocumentsModel()
    model.document = .driversLicense
    model.frontImage = .init(image: .init(), data: .init(), type: .image)
    model.backImage = .init(image: .init(), data: .init(), type: .image)
    model.documentCountry = .init(name: "USA", code: "US")
    model.additionalDocuments = [.init(image: .init(), data: .init(), type: .pdf)]
    let isFilled = UserDocumentsValidator.isFilled(for: model)
    XCTAssertTrue(isFilled)
  }
  
  func testSuccessIsUsDocumentCountry() {
    var model = UserDocumentsModel()
    model.document = .driversLicense
    model.frontImage = .init(image: .init(), data: .init(), type: .image)
    model.backImage = .init(image: .init(), data: .init(), type: .image)
    model.documentCountry = .init(name: "USA", code: "US")
    model.isAddressOnDocument = .yes
    let isFilled = UserDocumentsValidator.isFilled(for: model)
    XCTAssertTrue(isFilled)
  }
  
  func testFailure() {
    let model = UserDocumentsModel()
    let isFilled = UserDocumentsValidator.isFilled(for: model)
    XCTAssertFalse(isFilled)
  }
  
}
