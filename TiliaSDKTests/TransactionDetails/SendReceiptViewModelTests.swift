//
//  SendReceiptViewModelTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 02.09.2022.
//

import XCTest
import Combine
@testable import TiliaSDK

final class SendReceiptViewModelTests: XCTestCase {
  
  var subscriptions: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    subscriptions = []
  }
  
  func testSuccessSend() {
    var emailSent: Void?
    var loading: Bool?
    var isEmailValid: Bool?
    
    let emailSentExpectation = XCTestExpectation(description: "testSuccessSend_EmailSent")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = SendReceiptViewModel(transactionId: "",
                                         manager: networkManager,
                                         onEmailSent: { emailSent = (); emailSentExpectation.fulfill() },
                                         onError: nil)
    
    let loadingExpectation = XCTestExpectation(description: "testSuccessSend_Loading")
    viewModel.loading.sink {
      loading = $0
      loadingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let isEmailValidExpectation = XCTestExpectation(description: "testSuccessSend_IsEmailValid")
    viewModel.isEmailValid.sink {
      isEmailValid = $0
      isEmailValidExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    let email = "test@gmail.com"
    viewModel.checkEmail(email)
    viewModel.sendEmail(email)
    viewModel.complete()
    
    let expectations = [
      emailSentExpectation,
      loadingExpectation,
      isEmailValidExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(loading)
    XCTAssertEqual(isEmailValid, true)
    XCTAssertNotNil(emailSent)
  }
  
  func testFailureSend() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testFailureSend_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    
    let viewModel = SendReceiptViewModel(transactionId: "",
                                         manager: networkManager,
                                         onEmailSent: { },
                                         onError: { errorCallback = $0; errorCallbackExpectation.fulfill() })
    
    let errorExpectation = XCTestExpectation(description: "testFailureSend_Error")
    viewModel.error.sink {
      error = $0
      errorExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken("")
    viewModel.sendEmail("test@gmail.com")
    
    let expectations = [
      errorExpectation,
      errorCallbackExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
}
