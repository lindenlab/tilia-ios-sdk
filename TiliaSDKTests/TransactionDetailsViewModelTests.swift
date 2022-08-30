//
//  TransactionDetailsViewModelTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 31.08.2022.
//

import XCTest
import Combine
@testable import TiliaSDK

final class TransactionDetailsViewModelTests: XCTestCase {
  
  var subscriptions: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    subscriptions = []
  }
  
  func testSuccessGetTransactionDetails() {
    var loading: Bool?
    var needToAcceptTos: Void?
    var completeCallback: TLCompleteCallback?
    
    let completeCallbackExpectation = XCTestExpectation(description: "testSuccessGetTransactionDetails_CompleteCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = TransactionDetailsViewModel(invoiceId: "",
                                                manager: networkManager,
                                                onUpdate: nil,
                                                onComplete: { completeCallback = $0; completeCallbackExpectation.fulfill() },
                                                onError: nil)
    
    let loadingExpectation = XCTestExpectation(description: "testSuccessGetTransactionDetails_Loading")
    viewModel.loading.sink {
      loading = $0
      loadingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let needToAcceptTosExpectation = XCTestExpectation(description: "testSuccessGetTransactionDetails_NeedToAcceptTos")
    viewModel.needToAcceptTos.sink { [weak viewModel] in
      needToAcceptTos = $0
      needToAcceptTosExpectation.fulfill()
      let event = TLCompleteCallback(event: TLEvent(flow: .tos, action: .completed),
                                     state: .completed)
      viewModel?.onTosComplete(event)
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.checkIsTosRequired()
    
    wait(for: [loadingExpectation, needToAcceptTosExpectation], timeout: 2)
    XCTAssertNotNil(loading)
    XCTAssertNotNil(needToAcceptTos)
    XCTAssertEqual(completeCallback?.state, .completed)
  }
  
  func testErrorCheckIsTosRequired() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testErrorCheckIsTosRequired_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = TransactionDetailsViewModel(invoiceId: "",
                                                manager: networkManager,
                                                onUpdate: nil,
                                                onComplete: nil,
                                                onError: { errorCallback = $0; errorCallbackExpectation.fulfill() })
    
    let errorExpectation = XCTestExpectation(description: "testErrorCheckIsTosRequired_Error")
    viewModel.error.sink {
      error = $0.error
      errorExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken("")
    viewModel.checkIsTosRequired()
    
    wait(for: [errorExpectation, errorCallbackExpectation], timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
  func testErrorGetTransactionDetails() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testErrorCheckIsTosRequired_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = TransactionDetailsViewModel(invoiceId: "",
                                                manager: networkManager,
                                                onUpdate: nil,
                                                onComplete: nil,
                                                onError: { errorCallback = $0; errorCallbackExpectation.fulfill() })
    
    let needToAcceptTosExpectation = XCTestExpectation(description: "testSuccessGetTransactionDetails_NeedToAcceptTos")
    viewModel.needToAcceptTos.sink { [weak viewModel] in
      TLManager.shared.setToken("")
      needToAcceptTosExpectation.fulfill()
      let event = TLCompleteCallback(event: TLEvent(flow: .tos, action: .completed),
                                     state: .completed)
      viewModel?.onTosComplete(event)
    }.store(in: &subscriptions)
    
    let errorExpectation = XCTestExpectation(description: "testErrorAcceptTos_Error")
    viewModel.error.sink {
      error = $0.error
      errorExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.checkIsTosRequired()
    
    wait(for: [errorExpectation, errorCallbackExpectation], timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
}
