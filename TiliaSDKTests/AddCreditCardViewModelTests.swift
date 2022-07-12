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
                                           onReload: { needToReload = $0; reloadExpectation.fulfill() },
                                           onError: nil)
    
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
    
    TLManager.shared.setToken(UUID().uuidString)
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
  
  func testErrorOpenBrowser() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    var needToReload: Bool?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testErrorOpenBrowser_ErrorCallback")
    let reloadExpectation = XCTestExpectation(description: "testErrorOpenBrowser_Reload")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = AddCreditCardViewModel(manager: networkManager,
                                           onReload: { needToReload = $0; reloadExpectation.fulfill() },
                                           onError: { errorCallback = $0; errorCallbackExpectation.fulfill() })
    
    let errorExpectation = XCTestExpectation(description: "testErrorOpenBrowser_Error")
    viewModel.error.sink { [weak viewModel] in
      error = $0
      viewModel?.complete()
      errorExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken("")
    viewModel.openBrowser()
    
    wait(for: [errorExpectation, errorCallbackExpectation, reloadExpectation], timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
    XCTAssertEqual(needToReload, false)
  }
  
}
