//
//  TosViewModelTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 12.04.2022.
//

import XCTest
import Combine
@testable import TiliaSDK

final class TosViewModelTests: XCTestCase {
  
  var subscriptions: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    subscriptions = []
  }
  
  func testSuccessAcceptTos() {
    var accept: Bool?
    var loading: Bool?
    var completeCallback: TLCompleteCallback?
    
    let completeCallbackExpectation = XCTestExpectation(description: "testSuccessAcceptTos_CompleteCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = TosViewModel(manager: networkManager,
                                 onComplete: { completeCallback = $0; completeCallbackExpectation.fulfill() },
                                 onError: nil)
    
    let acceptExpectation = XCTestExpectation(description: "testSuccessAcceptTos_Accept")
    viewModel.accept.sink { [weak viewModel] in
      accept = $0
      if $0 {
        viewModel?.complete()
        acceptExpectation.fulfill()
      }
    }.store(in: &subscriptions)
    
    let loadingExpectation = XCTestExpectation(description: "testSuccessAcceptTos_Loading")
    viewModel.loading.sink {
      loading = $0
      loadingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.acceptTos()
    
    wait(for: [acceptExpectation, loadingExpectation, completeCallbackExpectation], timeout: 2)
    XCTAssertEqual(accept, true)
    XCTAssertNotNil(loading)
    XCTAssertEqual(completeCallback?.state, .completed)
  }
  
  func testErrorAcceptTos() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testErrorAcceptTos_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = TosViewModel(manager: networkManager,
                                 onComplete: nil,
                                 onError: { errorCallback = $0; errorCallbackExpectation.fulfill() })
    
    let errorExpectation = XCTestExpectation(description: "testErrorAcceptTos_Error")
    viewModel.error.sink {
      error = $0
      errorExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken("")
    viewModel.acceptTos()
    
    wait(for: [errorExpectation, errorCallbackExpectation], timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
}
