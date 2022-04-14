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
  
  var subscriptions: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    subscriptions = []
  }
  
  func testSuccessAcceptTos() {
    var accept: Bool?
    var loading: Bool?
    var completeCallback: TLCompleteCallback?
    
    let completeCallbackExpactation = XCTestExpectation(description: "testSuccessAcceptTos_CompleteCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = TosViewModel(manager: networkManager,
                                 onComplete: { completeCallback = $0; completeCallbackExpactation.fulfill() },
                                 onError: nil)
    
    let acceptExpactation = XCTestExpectation(description: "testSuccessAcceptTos_Accept")
    viewModel.accept.sink { [weak viewModel] in
      accept = $0
      if $0 {
        viewModel?.complete()
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
    
    wait(for: [acceptExpactation, loadingExpactation, completeCallbackExpactation], timeout: 2)
    XCTAssertEqual(accept, true)
    XCTAssertNotNil(loading)
    XCTAssertEqual(completeCallback?.state, .completed)
  }
  
  func testErrorAcceptTos() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpactation = XCTestExpectation(description: "testErrorAcceptTos_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = TosViewModel(manager: networkManager,
                                 onComplete: nil,
                                 onError: { errorCallback = $0; errorCallbackExpactation.fulfill() })
    
    let errorExpactation = XCTestExpectation(description: "testErrorAcceptTos_Error")
    viewModel.error.sink {
      error = $0
      errorExpactation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken("")
    viewModel.acceptTos()
    
    wait(for: [errorExpactation, errorCallbackExpactation], timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
}
