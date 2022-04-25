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
    
    let completeCallbackExpactation = XCTestExpectation(description: "testSuccessCheckIsTosRequired_CompleteCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = CheckoutViewModel(invoiceId: "",
                                      manager: networkManager,
                                      onUpdate: nil,
                                      onComplete: { completeCallback = $0; completeCallbackExpactation.fulfill() },
                                      onError: nil)
    
    let loadingExpactation = XCTestExpectation(description: "testSuccessCheckIsTosRequired_Loading")
    viewModel.loading.sink {
      loading = $0
      loadingExpactation.fulfill()
    }.store(in: &subscriptions)
    
    let needToAcceptTosExpactation = XCTestExpectation(description: "testSuccessCheckIsTosRequired_NeedToAcceptTos")
    viewModel.needToAcceptTos.sink { [weak viewModel] in
      needToAcceptTos = $0
      needToAcceptTosExpactation.fulfill()
      let event = TLCompleteCallback(event: TLEvent(flow: .tos, action: .completed),
                                     state: .completed)
      viewModel?.onTosComplete(event)
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.checkIsTosRequired()
    
    wait(for: [loadingExpactation, needToAcceptTosExpactation], timeout: 2)
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
    
    let updateCallbackExpactation = XCTestExpectation(description: "testSuccessPayInvoice_UpdateCallback")
    let completeCallbackExpactation = XCTestExpectation(description: "testSuccessPayInvoice_CompleteCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = CheckoutViewModel(invoiceId: "",
                                      manager: networkManager,
                                      onUpdate: { updateCallback = $0; updateCallbackExpactation.fulfill() },
                                      onComplete: { completeCallback = $0; completeCallbackExpactation.fulfill() },
                                      onError: nil)
    
    let loadingExpactation = XCTestExpectation(description: "testSuccessPayInvoice_Loading")
    viewModel.loading.sink {
      loading = $0
      loadingExpactation.fulfill()
    }.store(in: &subscriptions)
    
    let contentExpactation = XCTestExpectation(description: "testSuccessPayInvoice_Content")
    viewModel.content.sink { [weak viewModel] _ in
      viewModel?.selectPaymentMethod(at: 0)
      contentExpactation.fulfill()
    }.store(in: &subscriptions)
    
    let selectIndexExpactation = XCTestExpectation(description: "testSuccessPayInvoice_SelectIndex")
    viewModel.selectIndex.sink {
      selectIndex = $0
      selectIndexExpactation.fulfill()
    }.store(in: &subscriptions)
    
    let payButtonIsEnabledExpactation = XCTestExpectation(description: "testSuccessPayInvoice_PayButtonIsEnabled")
    viewModel.payButtonIsEnabled.sink { [weak viewModel] in
      if $0 {
        viewModel?.payInvoice()
        payButtonIsEnabledExpactation.fulfill()
      }
    }.store(in: &subscriptions)
    
    let successfulPaymentExpactation = XCTestExpectation(description: "testSuccessPayInvoice_SuccessfulPayment")
    viewModel.successfulPayment.sink {
      if $0 {
        successfulPayment = $0
        successfulPaymentExpactation.fulfill()
      }
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    let event = TLCompleteCallback(event: TLEvent(flow: .tos, action: .completed),
                                   state: .completed)
    viewModel.onTosComplete(event)
    
    let expectations = [
      loadingExpactation,
      contentExpactation,
      successfulPaymentExpactation,
      updateCallbackExpactation,
      selectIndexExpactation,
      payButtonIsEnabledExpactation
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
    
    let errorCallbackExpactation = XCTestExpectation(description: "testErrorCheckIsTosRequired_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = CheckoutViewModel(invoiceId: "",
                                      manager: networkManager,
                                      onUpdate: nil,
                                      onComplete: nil,
                                      onError: { errorCallback = $0; errorCallbackExpactation.fulfill() })
    
    let errorExpactation = XCTestExpectation(description: "testErrorCheckIsTosRequired_Error")
    viewModel.error.sink {
      error = $0.error
      errorExpactation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken("")
    viewModel.checkIsTosRequired()
    
    wait(for: [errorExpactation, errorCallbackExpactation], timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
  func testErrorPayInvoice() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpactation = XCTestExpectation(description: "testErrorPayInvoice_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = CheckoutViewModel(invoiceId: "",
                                      manager: networkManager,
                                      onUpdate: nil,
                                      onComplete: nil,
                                      onError: { errorCallback = $0; errorCallbackExpactation.fulfill() })
        
    let errorExpactation = XCTestExpectation(description: "testErrorPayInvoice_Error")
    viewModel.error.sink {
      error = $0.error
      errorExpactation.fulfill()
    }.store(in: &subscriptions)
    
    let contentExpactation = XCTestExpectation(description: "testErrorPayInvoice_Content")
    viewModel.content.sink { [weak viewModel] _ in
      viewModel?.selectPaymentMethod(at: 0)
      contentExpactation.fulfill()
    }.store(in: &subscriptions)
    
    let payButtonIsEnabledExpactation = XCTestExpectation(description: "testSuccessPayInvoice_PayButtonIsEnabled")
    viewModel.payButtonIsEnabled.sink { [weak viewModel] in
      if $0 {
        TLManager.shared.setToken("")
        viewModel?.payInvoice()
        payButtonIsEnabledExpactation.fulfill()
      }
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    let event = TLCompleteCallback(event: TLEvent(flow: .tos, action: .completed),
                                   state: .completed)
    viewModel.onTosComplete(event)
    
    let expectations = [
      errorExpactation,
      contentExpactation,
      payButtonIsEnabledExpactation
    ]
    wait(for: expectations, timeout: 4)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
}
