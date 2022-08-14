//
//  TosContentViewModelsTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 14.08.2022.
//

import XCTest
import Combine
@testable import TiliaSDK

final class TosContentViewModelsTests: XCTestCase {
  
  var subscriptions: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    subscriptions = []
  }
  
  func testSuccessGetTosContent() {
    var content: String?
    var loading: Bool?
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = TosContentViewModel(manager: networkManager,
                                        onError: nil)
    
    let contentExpectation = XCTestExpectation(description: "testSuccessGetTosContent_Content")
    viewModel.content.sink {
      contentExpectation.fulfill()
      content = $0
    }.store(in: &subscriptions)
    
    let loadingExpectation = XCTestExpectation(description: "testSuccessGetTosContent_Loading")
    viewModel.loading.sink {
      loading = $0
      loadingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    viewModel.loadContent()
    
    wait(for: [contentExpectation, loadingExpectation], timeout: 2)
    XCTAssertNotNil(content)
    XCTAssertNotNil(loading)
  }
  
}
