//
//  UserDocumentsViewModelTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 20.07.2022.
//

import XCTest
import Combine
@testable import TiliaSDK

final class UserDocumentsViewModelTests: XCTestCase {
  
  var subscriptions: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    subscriptions = []
  }
  
  func testSuccessSetText() {
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let userInfoModel = UserInfoModel(countryOfResidence: CountryModel.usa)
    let viewModel = UserDocumentsViewModel(manager: networkManager,
                                           userInfoModel: userInfoModel,
                                           onComplete: { _ in },
                                           onError: nil)
    /*
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
    */
    
    
  }
  
}
