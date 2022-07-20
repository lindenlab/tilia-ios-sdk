//
//  UserInfoViewModelTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 20.07.2022.
//

import XCTest
import Combine
@testable import TiliaSDK

final class UserInfoViewModelTests: XCTestCase {
  
  var subscriptions: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    subscriptions = []
  }
  
  func testSuccessUpdateSection() {
    var sectionIndex: Int?
    var isSectionExpanded: Bool?
    var isSectionFilled: Bool?
    var nextSectionIndex: Int?
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = UserInfoViewModel(manager: networkManager,
                                      onComplete: nil,
                                      onError: nil)
    
    let expandExpectation = XCTestExpectation(description: "testSuccessUpdateSection_Expand")
    viewModel.expandSection.sink {
      sectionIndex = $0.index
      isSectionExpanded = $0.isExpanded
      isSectionFilled = $0.isFilled
      nextSectionIndex = $0.nextIndex
      expandExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let section = UserInfoSectionBuilder.Section(type: .location,
                                                 mode: .normal,
                                                 isFilled: false,
                                                 items: [])
    viewModel.updateSection(section, at: 0, isExpanded: true, nextSectionIndex: 1)
    
    wait(for: [expandExpectation], timeout: 2)
    XCTAssertEqual(sectionIndex, 0)
    XCTAssertEqual(isSectionExpanded, true)
    XCTAssertEqual(isSectionFilled, false)
    XCTAssertEqual(nextSectionIndex, 1)
  }
  
  func testSuccessSetText() {
    var text: String?
    var isUsSelected: Bool?
    var isCountryChanged: Bool?
    var wasUsResidence: Bool?
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = UserInfoViewModel(manager: networkManager,
                                      onComplete: nil,
                                      onError: nil)
    
    let setSectionTextExpectation = XCTestExpectation(description: "testSuccessSetText_SetSectionText")
    viewModel.setSectionText.sink {
      text = $0.text
      setSectionTextExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let coutryOfResidenceDidChangeExpectation = XCTestExpectation(description: "testSuccessSetText_CoutryOfResidenceDidChange")
    viewModel.coutryOfResidenceDidChange.sink {
      isCountryChanged = !$0.model.isUsResident
      wasUsResidence = $0.wasUsResidence
      coutryOfResidenceDidChangeExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let coutryOfResidenceDidSelectExpectation = XCTestExpectation(description: "testSuccessSetText_CoutryOfResidenceDidSelect")
    viewModel.coutryOfResidenceDidSelect.sink {
      isUsSelected = $0.isUsResident
      coutryOfResidenceDidSelectExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let item = UserInfoSectionBuilder.Section.Item(mode: .fields(.init(type: .countryOfResidance,
                                                                       fields: [.init(placeholder: nil, text: nil)])),
                                                   title: nil,
                                                   description: nil)
    let section = UserInfoSectionBuilder.Section(type: .location,
                                                 mode: .normal,
                                                 isFilled: false,
                                                 items: [item])
    viewModel.setText(Locale.current.localizedString(forRegionCode: "US"),
                      for: section,
                      indexPath: .init(row: 0, section: 0), fieldIndex: 0)
    viewModel.setText(Locale.current.localizedString(forRegionCode: "CA"),
                      for: section,
                      indexPath: .init(row: 0, section: 0), fieldIndex: 0)
    
    let expectations = [
      setSectionTextExpectation,
      coutryOfResidenceDidChangeExpectation,
      coutryOfResidenceDidSelectExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertEqual(text, Locale.current.localizedString(forRegionCode: "CA"))
    XCTAssertEqual(isUsSelected, true)
    XCTAssertEqual(isCountryChanged, true)
    XCTAssertEqual(wasUsResidence, true)
  }
  
  func testSuccessComplete() {
    var isUploaded: Bool?
    
    let completeExpectation = XCTestExpectation(description: "testSuccessComplete_Complete")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = UserInfoViewModel(manager: networkManager,
                                      onComplete: { isUploaded = $0; completeExpectation.fulfill() },
                                      onError: nil)
    
    viewModel.onUserDocumentsComplete(true)
    viewModel.complete()
    
    wait(for: [completeExpectation], timeout: 2)
    XCTAssertEqual(isUploaded, true)
  }
  
}
