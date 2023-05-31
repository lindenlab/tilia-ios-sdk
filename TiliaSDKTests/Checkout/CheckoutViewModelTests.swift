//
//  CheckoutViewModelTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 12.04.2022.
//

import XCTest
import Combine
@testable import TiliaSDK

final class CheckoutViewModelTests: XCTestCase {
  
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
    var deselectIndex: Int?
    var paymentMethodsAreEnabled: Bool?
    var createInvoiceLoading: Bool?
    var updateSummary: InvoiceInfoModel?
    
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
    
    let createInvoiceLoadingExpectation = XCTestExpectation(description: "testSuccessPayInvoice_CreateInvoiceLoading")
    viewModel.createInvoiceLoading.sink {
      createInvoiceLoading = $0
      createInvoiceLoadingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let contentExpectation = XCTestExpectation(description: "testSuccessPayInvoice_Content")
    viewModel.content.sink { [weak viewModel] _ in
      viewModel?.selectPaymentMethod(at: .init(row: 0, section: 0), isSelected: true)
      contentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let selectIndexExpectation = XCTestExpectation(description: "testSuccessPayInvoice_SelectIndex")
    viewModel.selectIndex.sink {
      selectIndex = $0.row
      selectIndexExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let deselectIndexExpectation = XCTestExpectation(description: "testSuccessPayInvoice_DeselectIndex")
    viewModel.deselectIndex.sink {
      deselectIndex = $0.row
      deselectIndexExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let paymentMethodsAreEnabledExpectation = XCTestExpectation(description: "testSuccessPayInvoice_PaymentMethodsAreEnabled")
    viewModel.paymentMethodsAreEnabled.sink {
      paymentMethodsAreEnabled = $0.isEnabled
      paymentMethodsAreEnabledExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let updateSummaryExpectation = XCTestExpectation(description: "testSuccessPayInvoice_UpdateSummary")
    viewModel.updateSummary.sink {
      updateSummary = $0
      updateSummaryExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let payButtonIsEnabledExpectation = XCTestExpectation(description: "testSuccessPayInvoice_PayButtonIsEnabled")
    viewModel.payButtonIsEnabled.sink { [weak viewModel] in
      guard $0.isEnabled else { return }
      if selectIndex == 0 {
        viewModel?.selectPaymentMethod(at: .init(row: 0, section: 0), isSelected: false)
        viewModel?.selectPaymentMethod(at: .init(row: 1, section: 0))
      } else if selectIndex == 1 {
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
      payButtonIsEnabledExpectation,
      paymentMethodsAreEnabledExpectation,
      createInvoiceLoadingExpectation,
      updateSummaryExpectation
    ]
    wait(for: expectations, timeout: 6)
    XCTAssertNotNil(loading)
    XCTAssertEqual(successfulPayment, true)
    XCTAssertEqual(updateCallback?.event.action, .paymentProcessed)
    XCTAssertEqual(completeCallback?.state, .completed)
    XCTAssertEqual(selectIndex, 1)
    XCTAssertEqual(deselectIndex, 0)
    XCTAssertEqual(paymentMethodsAreEnabled, true)
    XCTAssertNotNil(createInvoiceLoading)
    XCTAssertNotNil(updateSummary)
  }
  
  func testSuccessRenamePaymentMethod() {
    var updateCallback: TLUpdateCallback?
    var updatePayment: CheckoutContent?
    
    let updateCallbackExpectation = XCTestExpectation(description: "testSuccessRenamePaymentMethod_UpdateCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = CheckoutViewModel(invoiceId: "",
                                      manager: networkManager,
                                      onUpdate: { updateCallback = $0; updateCallbackExpectation.fulfill() },
                                      onComplete: nil,
                                      onError: nil)
    
    let contentExpectation = XCTestExpectation(description: "testSuccessRenamePaymentMethod_Content")
    viewModel.content.sink { [weak viewModel] _ in
      viewModel?.renamePaymentMethod(at: 1, with: "newName")
      contentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let updatePaymentExpectation = XCTestExpectation(description: "testSuccessRenamePaymentMethod_UpdatePayment")
    viewModel.updatePayment.sink {
      updatePayment = $0
      updatePaymentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    let event = TLCompleteCallback(event: TLEvent(flow: .tos, action: .completed),
                                   state: .completed)
    viewModel.onTosComplete(event)
    
    let expectations = [
      updateCallbackExpectation,
      updatePaymentExpectation,
      contentExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(updatePayment)
    XCTAssertEqual(updateCallback?.event.action, .paymentMethodRenamed)
    XCTAssertEqual(updateCallback?.event.flow, .checkout)
  }
  
  func testSuccessDeletePaymentMethod() {
    var updateCallback: TLUpdateCallback?
    var updatePayment: CheckoutContent?
    
    let updateCallbackExpectation = XCTestExpectation(description: "testSuccessDeletePaymentMethod_UpdateCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = CheckoutViewModel(invoiceId: "",
                                      manager: networkManager,
                                      onUpdate: { updateCallback = $0; updateCallbackExpectation.fulfill() },
                                      onComplete: nil,
                                      onError: nil)
    
    let contentExpectation = XCTestExpectation(description: "testSuccessDeletePaymentMethod_Content")
    viewModel.content.sink { [weak viewModel] _ in
      viewModel?.removePaymentMethod(at: 1)
      contentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let updatePaymentExpectation = XCTestExpectation(description: "testSuccessDeletePaymentMethod_UpdatePayment")
    viewModel.updatePayment.sink {
      updatePayment = $0
      updatePaymentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    let event = TLCompleteCallback(event: TLEvent(flow: .tos, action: .completed),
                                   state: .completed)
    viewModel.onTosComplete(event)
    
    let expectations = [
      updateCallbackExpectation,
      updatePaymentExpectation,
      contentExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(updatePayment)
    XCTAssertEqual(updateCallback?.event.action, .paymentMethodDeleted)
    XCTAssertEqual(updateCallback?.event.flow, .checkout)
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
      viewModel?.selectPaymentMethod(at: .init(row: 0, section: 0))
      contentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let payButtonIsEnabledExpectation = XCTestExpectation(description: "testSuccessPayInvoice_PayButtonIsEnabled")
    viewModel.payButtonIsEnabled.sink { [weak viewModel] in
      if $0.isEnabled {
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
