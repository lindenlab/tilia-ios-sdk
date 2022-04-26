//
//  AddCreditCardViewModelTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 26.04.2022.
//

import XCTest
import Combine
@testable import TiliaSDK

class AddCreditCardViewModelTests: XCTestCase {
  
  var subscriptions: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    subscriptions = []
  }
  
  func testSuccessOpenBrowser() {
    var loading: Bool?
    var needToReload: Bool?
    var url: URL?
    
    let reloadExpectation = XCTestExpectation(description: "testSuccessOpenBrowser_Reload")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = AddCreditCardViewModel(manager: networkManager,
                                           onReload: { needToReload = $0; reloadExpectation.fulfill() })
    
    let loadingExpectation = XCTestExpectation(description: "testSuccessOpenBrowser_Loading")
    viewModel.loading.sink {
      loading = $0
      loadingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let openUrlExpectation = XCTestExpectation(description: "testSuccessOpenBrowser_OpenUrl")
    viewModel.openUrl.sink { [weak viewModel] in
      url = $0
      viewModel?.complete()
      openUrlExpectation.fulfill()
    }.store(in: &subscriptions)
    
    viewModel.openBrowser()
    
    let expectations = [
      reloadExpectation,
      loadingExpectation,
      openUrlExpectation
    ]
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(loading)
    XCTAssertEqual(needToReload, true)
    XCTAssertNotNil(url)
  }
  
  func testError() {
    // TODO: - Need to add later
  }
  
}
