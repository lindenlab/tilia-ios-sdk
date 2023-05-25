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
    var loading: Bool?
    var defaultEmail: String?
    var emailSent: Void?
    var sending: Bool?
    var isEmailValid: Bool?
    var emailVerificationMode: SendReceiptMode?
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = SendReceiptViewModel(transactionId: "",
                                         manager: networkManager,
                                         onEmailSent: { },
                                         onUpdate: nil,
                                         onError: nil)
    
    let loadingExpectation = XCTestExpectation(description: "testSuccessSend_Loading")
    viewModel.loading.sink {
      loading = $0
      loadingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let defaultEmailExpectation = XCTestExpectation(description: "testSuccessSend_DefaultEmail")
    viewModel.defaultEmail.sink {
      defaultEmail = $0
      defaultEmailExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let emailVerificationModeExpectation = XCTestExpectation(description: "testSuccessSend_EmailVerificationMode")
    viewModel.emailVerificationMode.sink { [weak viewModel] in
      emailVerificationMode = $0
      viewModel?.sendEmail(defaultEmail ?? "")
      emailVerificationModeExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let sendingExpectation = XCTestExpectation(description: "testSuccessSend_Sending")
    viewModel.sending.sink {
      sending = $0
      sendingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let isEmailValidExpectation = XCTestExpectation(description: "testSuccessSend_IsEmailValid")
    viewModel.isEmailValid.sink {
      isEmailValid = $0
      isEmailValidExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let emailSentExpectation = XCTestExpectation(description: "testSuccessSend_EmailSent")
    viewModel.emailSent.sink {
      emailSent = ()
      emailSentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.load()
    
    let expectations = [
      loadingExpectation,
      defaultEmailExpectation,
      emailVerificationModeExpectation,
      emailSentExpectation,
      sendingExpectation,
      isEmailValidExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(loading)
    XCTAssertNotNil(defaultEmail)
    XCTAssertEqual(emailVerificationMode, .verified)
    XCTAssertNotNil(sending)
    XCTAssertEqual(isEmailValid, true)
    XCTAssertNotNil(emailSent)
  }
  
  func testSuccessUpdateEmail() {
    var defaultEmail: String?
    var emailVerificationMode: SendReceiptMode?
    var verifyEmail: Void?
    var emailVerified: String?
    var updateCallback: TLUpdateCallback?
    
    let onUpdateExpectation = XCTestExpectation(description: "testSuccessSend_OnUpdate")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = SendReceiptViewModel(transactionId: "",
                                         manager: networkManager,
                                         onEmailSent: { },
                                         onUpdate: { updateCallback = $0; onUpdateExpectation.fulfill() },
                                         onError: nil)
    
    let defaultEmailExpectation = XCTestExpectation(description: "testSuccessSend_DefaultEmail")
    viewModel.defaultEmail.sink {
      defaultEmail = $0
      defaultEmailExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let emailVerificationModeExpectation = XCTestExpectation(description: "testSuccessSend_EmailVerificationMode")
    viewModel.emailVerificationMode.sink { [weak viewModel] in
      switch $0 {
      case .verified where emailVerificationMode == nil:
        emailVerificationMode = $0
        viewModel?.editEmail()
      case .edit:
        viewModel?.sendEmail((defaultEmail ?? "").replacingOccurrences(of: "lindenlab", with: "gmail"))
      default:
        break
      }
      emailVerificationModeExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let verifyEmailExpectation = XCTestExpectation(description: "testSuccessSend_VerifyEmail")
    viewModel.verifyEmail.sink { [weak viewModel] in
      verifyEmail = ()
      viewModel?.onEmailVerified(viewModel?.verifyEmailMode ?? .update)
      verifyEmailExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let emailVerifiedExpectation = XCTestExpectation(description: "testSuccessSend_EmailVerified")
    viewModel.emailVerified.sink {
      emailVerified = $0
      emailVerifiedExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.load()
    
    let expectations = [
      defaultEmailExpectation,
      emailVerificationModeExpectation,
      verifyEmailExpectation,
      emailVerifiedExpectation,
      onUpdateExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(defaultEmail)
    XCTAssertEqual(emailVerificationMode, .verified)
    XCTAssertNotNil(emailVerified)
    XCTAssertNotNil(verifyEmail)
    XCTAssertEqual(updateCallback?.event.action, .emailVerified)
  }
  
  func testFailureSend() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testFailureSend_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    
    let viewModel = SendReceiptViewModel(transactionId: "",
                                         manager: networkManager,
                                         onEmailSent: { },
                                         onUpdate: nil,
                                         onError: { errorCallback = $0; errorCallbackExpectation.fulfill() })
    
    let errorExpectation = XCTestExpectation(description: "testFailureSend_Error")
    viewModel.error.sink {
      error = $0.error
      errorExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken("")
    viewModel.load()
    
    let expectations = [
      errorExpectation,
      errorCallbackExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
}
