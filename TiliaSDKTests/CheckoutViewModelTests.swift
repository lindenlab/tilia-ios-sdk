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
  
  var viewModel: CheckoutViewModelProtocol!
  var subscriptions: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    viewModel = CheckoutViewModel(invoiceId: "", manager: networkManager)
    subscriptions = []
  }
  
  func testSuccessCheckIsTosRequired() {
    var loading: Bool?
    var needToAcceptTos: Void?
    
    let loadingExpactation = XCTestExpectation(description: "testSuccessCheckIsTosRequired_Loading")
    viewModel.loading.sink {
      loading = $0
      if !$0 {
        loadingExpactation.fulfill()
      }
    }.store(in: &subscriptions)
    
    let needToAcceptTosExpactation = XCTestExpectation(description: "testSuccessCheckIsTosRequired_NeedToAcceptTos")
    viewModel.needToAcceptTos.sink {
      needToAcceptTos = $0
      needToAcceptTosExpactation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.checkIsTosRequired()
    
    wait(for: [loadingExpactation, needToAcceptTosExpactation], timeout: 2)
    XCTAssertEqual(loading, false)
    XCTAssertNotNil(needToAcceptTos)
  }
  
  func testSuccessProceedCheckout() {
    var loading: Bool?
    var content: CheckoutContent?
    
    let loadingExpactation = XCTestExpectation(description: "testSuccessProceedCheckout_Loading")
    viewModel.loading.sink {
      loading = $0
      if !$0 {
        loadingExpactation.fulfill()
      }
    }.store(in: &subscriptions)
    
    let contentExpactation = XCTestExpectation(description: "testSuccessProceedCheckout_Content")
    viewModel.content.sink {
      content = $0
      contentExpactation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.proceedCheckout()
    
    wait(for: [loadingExpactation, contentExpactation], timeout: 2)
    XCTAssertEqual(loading, false)
    XCTAssertNotNil(content)
  }
  
  func testSuccessPayInvoice() {
    var loading: Bool?
    var successfulPayment: Bool?
    
    let loadingExpactation = XCTestExpectation(description: "testSuccessPayInvoice_Loading")
    viewModel.loading.sink {
      loading = $0
      if !$0 {
        loadingExpactation.fulfill()
      }
    }.store(in: &subscriptions)
    
    let contentExpactation = XCTestExpectation(description: "testSuccessPayInvoice_Content")
    viewModel.content.sink { [weak self] in
      if $0 != nil {
        self?.viewModel.payInvoice()
        contentExpactation.fulfill()
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
    viewModel.proceedCheckout()
    
    wait(for: [loadingExpactation, contentExpactation, successfulPaymentExpactation], timeout: 2)
    XCTAssertEqual(loading, false)
    XCTAssertEqual(successfulPayment, true)
  }
  
  func testErrorCheckIsTosRequired() {
    var error: Error?
    
    let expactation = XCTestExpectation(description: "testErrorCheckIsTosRequired")
    viewModel.error.sink {
      error = $0
      expactation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken("")
    viewModel.checkIsTosRequired()
    
    wait(for: [expactation], timeout: 2)
    XCTAssertNotNil(error)
  }
  
  func testErrorProceedCheckout() {
    var error: Error?
    
    let expactation = XCTestExpectation(description: "testErrorProceedCheckout")
    viewModel.error.sink {
      error = $0
      expactation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken("")
    viewModel.proceedCheckout()
    
    wait(for: [expactation], timeout: 2)
    XCTAssertNotNil(error)
  }
  
  func testErrorPayInvoice() {
    var error: Error?
    
    let errorExpactation = XCTestExpectation(description: "testErrorPayInvoice_Error")
    viewModel.error.sink {
      error = $0
      errorExpactation.fulfill()
    }.store(in: &subscriptions)
    
    let contentExpactation = XCTestExpectation(description: "testErrorPayInvoice_Content")
    viewModel.content.sink { [weak self] in
      if $0 != nil {
        TLManager.shared.setToken("")
        self?.viewModel.payInvoice()
        contentExpactation.fulfill()
      }
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.proceedCheckout()
    
    wait(for: [errorExpactation, contentExpactation], timeout: 2)
    XCTAssertNotNil(error)
  }
  
}
