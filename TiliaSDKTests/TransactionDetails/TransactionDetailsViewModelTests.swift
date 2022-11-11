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
    var transaction: TransactionDetailsModel?
    
    let completeCallbackExpectation = XCTestExpectation(description: "testSuccessGetTransactionDetails_CompleteCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = TransactionDetailsViewModel(mode: .id(""),
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
    
    let contentExpectation = XCTestExpectation(description: "testSuccessGetTransactionDetails_Content")
    viewModel.content.sink {
      transaction = $0
      contentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.checkIsTosRequired()
    
    let expectations = [
      loadingExpectation,
      needToAcceptTosExpectation,
      contentExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(loading)
    XCTAssertNotNil(needToAcceptTos)
    XCTAssertEqual(completeCallback?.state, .completed)
    XCTAssertNotNil(transaction)
  }
  
  func testErrorCheckIsTosRequired() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testErrorCheckIsTosRequired_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = TransactionDetailsViewModel(mode: .id(""),
                                                manager: networkManager,
                                                onUpdate: nil,
                                                onComplete: nil,
                                                onError: { errorCallback = $0; errorCallbackExpectation.fulfill() })
    
    let errorExpectation = XCTestExpectation(description: "testErrorCheckIsTosRequired_Error")
    viewModel.error.sink {
      error = $0
      errorExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken("")
    viewModel.checkIsTosRequired()
    
    let expectations = [
      errorExpectation,
      errorCallbackExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
  func testErrorGetTransactionDetails() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testErrorCheckIsTosRequired_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = TransactionDetailsViewModel(mode: .id(""),
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
      error = $0
      errorExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.checkIsTosRequired()
    
    let expectations = [
      errorExpectation,
      errorCallbackExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
  func testSuccessSendEmail() {
    var updateCallback: TLUpdateCallback?
    var emailSent: Void?
    
    let updateCallbackExpectation = XCTestExpectation(description: "testSuccessSendEmail_UpdateCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = TransactionDetailsViewModel(mode: .id(""),
                                                manager: networkManager,
                                                onUpdate: { updateCallback = $0; updateCallbackExpectation.fulfill() },
                                                onComplete: nil,
                                                onError: nil)
    
    let emailSentExpectation = XCTestExpectation(description: "testSuccessSendEmail_EmailSent")
    viewModel.emailSent.sink {
      emailSent = $0
      emailSentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    viewModel.onEmailSent()
    
    let expectations = [
      updateCallbackExpectation,
      emailSentExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(emailSent)
    XCTAssertEqual(updateCallback?.event.action, .receiptSent)
  }
  
}