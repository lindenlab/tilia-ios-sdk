//
//  TosViewModelTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 12.04.2022.
//

import XCTest
import Combine
@testable import TiliaSDK

class TosViewModelTests: XCTestCase {
  
  var viewModel: TosViewModelProtocol!
  var subscriptions: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    viewModel = TosViewModel(manager: networkManager)
    subscriptions = []
  }
  
  func testSuccessAcceptTos() {
    var accept: Bool?
    var loading: Bool?
    
    let acceptExpactation = XCTestExpectation(description: "testSuccessAcceptTos_Accept")
    viewModel.accept.sink {
      accept = $0
      if $0 {
        acceptExpactation.fulfill()
      }
    }.store(in: &subscriptions)
    
    let loadingExpactation = XCTestExpectation(description: "testSuccessAcceptTos_Loading")
    viewModel.loading.sink {
      loading = $0
      loadingExpactation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.acceptTos()
    
    wait(for: [acceptExpactation, loadingExpactation], timeout: 2)
    XCTAssertEqual(accept, true)
    XCTAssertNotNil(loading)
  }
  
  func testErrorAcceptTos() {
    var error: Error?
    
    let expactation = XCTestExpectation(description: "testErrorAcceptTos")
    viewModel.error.sink {
      error = $0
      expactation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken("")
    viewModel.acceptTos()
    
    wait(for: [expactation], timeout: 2)
    XCTAssertNotNil(error)
  }
  
}
