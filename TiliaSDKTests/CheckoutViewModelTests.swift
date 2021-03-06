//
//  CheckoutViewModelTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 12.04.2022.
//

import XCTest
import Combine
@testable import TiliaSDK

class CheckoutViewModelTests: XCTestCase {
  
  var subscriptions: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    subscriptions = []
  }
  
  func testSuccessCheckIsTosRequired() {
    var loading: Bool?
    var needToAcceptTos: Void?
    var completeCallback: TLCompleteCallback?
    
    let completeCallbackExpectation = XCTestExpectation(description: "testSuccessCheckIsTosRequired_CompleteCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = CheckoutViewModel(invoiceId: "",
                                      manager: networkManager,
                                      onUpdate: nil,
                                      onComplete: { completeCallback = $0; completeCallbackExpectation.fulfill() },
                                      onError: nil)
    
    let loadingExpectation = XCTestExpectation(description: "testSuccessCheckIsTosRequired_Loading")
    viewModel.loading.sink {
      loading = $0
      loadingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let needToAcceptTosExpectation = XCTestExpectation(description: "testSuccessCheckIsTosRequired_NeedToAcceptTos")
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
  
  func testSuccessPayInvoice() {
    var loading: Bool?
    var successfulPayment: Bool?
    var updateCallback: TLUpdateCallback?
    var completeCallback: TLCompleteCallback?
    var selectIndex: Int?
    
    let updateCallbackExpectation = XCTestExpectation(description: "testSuccessPayInvoice_UpdateCallback")
    let completeCallbackExpectation = XCTestExpectation(description: "testSuccessPayInvoice_CompleteCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = CheckoutViewModel(invoiceId: "",
                                      manager: networkManager,
                                      onUpdate: { updateCallback = $0; updateCallbackExpectation.fulfill() },
                                      onComplete: { completeCallback = $0; completeCallbackExpectation.fulfill() },
                                      onError: nil)
    
    let loadingExpectation = XCTestExpectation(description: "testSuccessPayInvoice_Loading")
    viewModel.loading.sink {
      loading = $0
      loadingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let contentExpectation = XCTestExpectation(description: "testSuccessPayInvoice_Content")
    viewModel.content.sink { [weak viewModel] _ in
      viewModel?.selectPaymentMethod(at: 0)
      contentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let selectIndexExpectation = XCTestExpectation(description: "testSuccessPayInvoice_SelectIndex")
    viewModel.selectIndex.sink {
      selectIndex = $0
      selectIndexExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let payButtonIsEnabledExpectation = XCTestExpectation(description: "testSuccessPayInvoice_PayButtonIsEnabled")
    viewModel.payButtonIsEnabled.sink { [weak viewModel] in
      if $0 {
        viewModel?.payInvoice()
        payButtonIsEnabledExpectation.fulfill()
      }
    }.store(in: &subscriptions)
    
    let successfulPaymentExpectation = XCTestExpectation(description: "testSuccessPayInvoice_SuccessfulPayment")
    viewModel.successfulPayment.sink {
      if $0 {
        successfulPayment = $0
        successfulPaymentExpectation.fulfill()
      }
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    let event = TLCompleteCallback(event: TLEvent(flow: .tos, action: .completed),
                                   state: .completed)
    viewModel.onTosComplete(event)
    
    let expectations = [
      loadingExpectation,
      contentExpectation,
      successfulPaymentExpectation,
      updateCallbackExpectation,
      selectIndexExpectation,
      payButtonIsEnabledExpectation
    ]
    wait(for: expectations, timeout: 6)
    XCTAssertNotNil(loading)
    XCTAssertEqual(successfulPayment, true)
    XCTAssertEqual(updateCallback?.event.action, .paymentProcessed)
    XCTAssertEqual(completeCallback?.state, .completed)
    XCTAssertEqual(selectIndex, 0)
  }
  
  func testErrorCheckIsTosRequired() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testErrorCheckIsTosRequired_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = CheckoutViewModel(invoiceId: "",
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
  
  func testErrorPayInvoice() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testErrorPayInvoice_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = CheckoutViewModel(invoiceId: "",
                                      manager: networkManager,
                                      onUpdate: nil,
                                      onComplete: nil,
                                      onError: { errorCallback = $0; errorCallbackExpectation.fulfill() })
        
    let errorExpectation = XCTestExpectation(description: "testErrorPayInvoice_Error")
    viewModel.error.sink {
      error = $0.error
      errorExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let contentExpectation = XCTestExpectation(description: "testErrorPayInvoice_Content")
    viewModel.content.sink { [weak viewModel] _ in
      viewModel?.selectPaymentMethod(at: 0)
      contentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let payButtonIsEnabledExpectation = XCTestExpectation(description: "testSuccessPayInvoice_PayButtonIsEnabled")
    viewModel.payButtonIsEnabled.sink { [weak viewModel] in
      if $0 {
        TLManager.shared.setToken("")
        viewModel?.payInvoice()
        payButtonIsEnabledExpectation.fulfill()
      }
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    let event = TLCompleteCallback(event: TLEvent(flow: .tos, action: .completed),
                                   state: .completed)
    viewModel.onTosComplete(event)
    
    let expectations = [
      errorExpectation,
      contentExpectation,
      payButtonIsEnabledExpectation
    ]
    wait(for: expectations, timeout: 4)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
}
