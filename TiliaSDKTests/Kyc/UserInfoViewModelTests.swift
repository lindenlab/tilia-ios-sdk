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
                                      onUpdate: nil,
                                      onComplete: nil,
                                      onError: nil)
    
    let expandExpectation = XCTestExpectation(description: "testSuccessUpdateSection")
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
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = UserInfoViewModel(manager: networkManager,
                                      onUpdate: nil,
                                      onComplete: nil,
                                      onError: nil)
    
    let setSectionTextExpectation = XCTestExpectation(description: "testSuccessSetText")
    viewModel.setSectionText.sink {
      text = $0.text
      setSectionTextExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let item = UserInfoSectionBuilder.Section.Item(mode: .fields(.init(type: .countryOfResidance,
                                                                       fields: [.init(accessibilityIdentifier: nil)])),
                                                   title: nil,
                                                   description: nil)
    let section = UserInfoSectionBuilder.Section(type: .location,
                                                 mode: .normal,
                                                 isFilled: false,
                                                 items: [item])
    let usaName = CountryModel.usa.name
    viewModel.setText(usaName,
                      for: section,
                      indexPath: .init(row: 0, section: 0), fieldIndex: 0)
    
    wait(for: [setSectionTextExpectation], timeout: 2)
    XCTAssertEqual(text, usaName)
  }
  
  func testSuccessSelectCountryOfResidence() {
    var coutryOfResidenceSelected: Void?
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = UserInfoViewModel(manager: networkManager,
                                      onUpdate: nil,
                                      onComplete: nil,
                                      onError: nil)
    
    let coutryOfResidenceDidSelectExpectation = XCTestExpectation(description: "testSuccessSelectCountryOfResidence")
    viewModel.coutryOfResidenceDidSelect.sink {
      coutryOfResidenceSelected = $0
      coutryOfResidenceDidSelectExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let item = UserInfoSectionBuilder.Section.Item(mode: .fields(.init(type: .countryOfResidance,
                                                                       fields: [.init(accessibilityIdentifier: nil)])),
                                                   title: nil,
                                                   description: nil)
    let section = UserInfoSectionBuilder.Section(type: .location,
                                                 mode: .normal,
                                                 isFilled: false,
                                                 items: [item])
    let usaName = CountryModel.usa.name
    viewModel.setText(usaName,
                      for: section,
                      indexPath: .init(row: 0, section: 0), fieldIndex: 0)
    
    wait(for: [coutryOfResidenceDidSelectExpectation], timeout: 2)
    XCTAssertNotNil(coutryOfResidenceSelected)
  }
  
  func testSuccessChangeCountryOfResidence() {
    var isCountryChanged: Bool?
    var wasUsResidence: Bool?
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = UserInfoViewModel(manager: networkManager,
                                      onUpdate: nil,
                                      onComplete: nil,
                                      onError: nil)
    
    let coutryOfResidenceDidChangeExpectation = XCTestExpectation(description: "testSuccessChangeCountryOfResidence")
    viewModel.coutryOfResidenceDidChange.sink {
      isCountryChanged = !$0.model.isUsResident
      wasUsResidence = $0.wasUsResidence
      coutryOfResidenceDidChangeExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let item = UserInfoSectionBuilder.Section.Item(mode: .fields(.init(type: .countryOfResidance,
                                                                       fields: [.init(accessibilityIdentifier: nil)])),
                                                   title: nil,
                                                   description: nil)
    let section = UserInfoSectionBuilder.Section(type: .location,
                                                 mode: .normal,
                                                 isFilled: false,
                                                 items: [item])
    let usaName = CountryModel.usa.name
    viewModel.setText(usaName,
                      for: section,
                      indexPath: .init(row: 0, section: 0), fieldIndex: 0)
    let canadaName = CountryModel.canada.name
    viewModel.setText(canadaName,
                      for: section,
                      indexPath: .init(row: 0, section: 0), fieldIndex: 0)
    
    wait(for: [coutryOfResidenceDidChangeExpectation], timeout: 2)
    XCTAssertEqual(isCountryChanged, true)
    XCTAssertEqual(wasUsResidence, true)
  }
  
  func testSuccessSubmit() {
    var uploading: Bool?
    var updateCallback: TLUpdateCallback?
    var completeCallback: TLCompleteCallback?
    
    let updateCallbackExpectation = XCTestExpectation(description: "testSuccessSubmit_UpdateCallback")
    let completeCallbackExpectation = XCTestExpectation(description: "testSuccessSubmit_CompleteCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = UserInfoViewModel(manager: networkManager,
                                      onUpdate: { updateCallback = $0; updateCallbackExpectation.fulfill() },
                                      onComplete: { completeCallback = $0; completeCallbackExpectation.fulfill() },
                                      onError: nil)
    
    let uploadingExpectation = XCTestExpectation(description: "testSuccessSubmit_Uploading")
    viewModel.uploading.sink {
      uploading = $0
      uploadingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    viewModel.successfulCompleting.sink { [weak viewModel] in
      viewModel?.complete(isFromCloseAction: false)
    }.store(in: &subscriptions)
    
    let item = UserInfoSectionBuilder.Section.Item(mode: .fields(.init(type: .countryOfResidance,
                                                                       fields: [.init(accessibilityIdentifier: nil)])),
                                                   title: nil,
                                                   description: nil)
    let section = UserInfoSectionBuilder.Section(type: .location,
                                                 mode: .normal,
                                                 isFilled: false,
                                                 items: [item])
    let usaName = CountryModel.usa.name
    viewModel.setText(usaName,
                      for: section,
                      indexPath: .init(row: 0, section: 0), fieldIndex: 0)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.upload()
    
    let expectations = [
      updateCallbackExpectation,
      completeCallbackExpectation,
      uploadingExpectation
    ]
    
    wait(for: expectations, timeout: 7)
    XCTAssertNotNil(uploading)
    XCTAssertEqual(updateCallback?.event.action, .kycInfoSubmitted)
    XCTAssertEqual(completeCallback?.event.action, .completed)
  }
  
  func testFailureSubmit() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testFailureSubmit_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = UserInfoViewModel(manager: networkManager,
                                      onUpdate: nil,
                                      onComplete: nil,
                                      onError: { errorCallback = $0; errorCallbackExpectation.fulfill() })
    
    let errorExpectation = XCTestExpectation(description: "testFailureSubmit_Error")
    viewModel.error.sink {
      error = $0.error
      errorExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let item = UserInfoSectionBuilder.Section.Item(mode: .fields(.init(type: .countryOfResidance,
                                                                       fields: [.init(accessibilityIdentifier: nil)])),
                                                   title: nil,
                                                   description: nil)
    let section = UserInfoSectionBuilder.Section(type: .location,
                                                 mode: .normal,
                                                 isFilled: false,
                                                 items: [item])
    let usaName = CountryModel.usa.name
    viewModel.setText(usaName,
                      for: section,
                      indexPath: .init(row: 0, section: 0), fieldIndex: 0)
    
    TLManager.shared.setToken("")
    viewModel.upload()
    
    let expectations = [
      errorCallbackExpectation,
      errorExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
  func testSuccessLoadContentAndUpdateEmail() {
    var content: Void?
    var didStartEditingEmail: UserInfoEditEmail?
    var verifyEmail: Void?
    var emailVerified: UserInfoEmailVerified?
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = UserInfoViewModel(manager: networkManager,
                                      onUpdate: nil,
                                      onComplete: nil,
                                      onError: nil)
    
    let contentExpectation = XCTestExpectation(description: "testSuccessLoadContentAndUpdateEmail_ContentExpectation")
    viewModel.content.sink { [weak viewModel] _ in
      content = ()
      viewModel?.startEditingEmail(at: 0)
      contentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let didStartEditingEmailExpectation = XCTestExpectation(description: "testSuccessLoadContentAndUpdateEmail_DidStartEditingEmail")
    viewModel.didStartEditingEmail.sink { [weak viewModel] in
      didStartEditingEmail = $0
      let item = UserInfoSectionBuilder.Section.Item(mode: .fields(.init(type: .email,
                                                                         fields: [.init(accessibilityIdentifier: nil)])),
                                                     title: nil,
                                                     description: nil)
      let section = UserInfoSectionBuilder.Section(type: .email,
                                                   mode: .normal,
                                                   isFilled: false,
                                                   items: [item])
      viewModel?.setText("test@gmail.com", for: section, indexPath: .init(row: 0, section: 0), fieldIndex: 0)
      viewModel?.updateEmail(at: $0.index)
      didStartEditingEmailExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let verifyEmailExpectation = XCTestExpectation(description: "testSuccessLoadContentAndUpdateEmail_VerifyEmail")
    viewModel.verifyEmail.sink { [weak viewModel] in
      verifyEmail = ()
      viewModel?.onEmailVerified(viewModel?.verifyEmailMode ?? .update)
      verifyEmailExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let emailVerifiedExpectation = XCTestExpectation(description: "testSuccessLoadContentAndUpdateEmail_EmailVerified")
    viewModel.emailVerified.sink {
      emailVerified = $0
      emailVerifiedExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let expectations = [
      contentExpectation,
      didStartEditingEmailExpectation,
      verifyEmailExpectation,
      emailVerifiedExpectation
    ]
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.load()
    
    wait(for: expectations, timeout: 2)
    
    XCTAssertNotNil(content)
    XCTAssertEqual(didStartEditingEmail?.index, 0)
    XCTAssertNotNil(verifyEmail)
    XCTAssertNotNil(emailVerified)
  }
  
}
