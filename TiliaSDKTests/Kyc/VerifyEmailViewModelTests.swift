//
//  VerifyEmailViewModelTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 17.05.2023.
//

import XCTest
import Combine
@testable import TiliaSDK

final class VerifyEmailViewModelTests: XCTestCase {
  
  var subscriptions: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    subscriptions = []
  }
  
  func testSuccessVerify() {
    var emailVerified: VerifyEmailMode?
    var loading: Bool?
    var updateCallback: TLUpdateCallback?
    
    let emailVerifiedExpectation = XCTestExpectation(description: "testSuccessVerify_EmailVerified")
    let updateCallbackExpectation = XCTestExpectation(description: "testSuccessVerify_UpdateCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = VerifyEmailViewModel(email: "test@gmail.com",
                                         flow: .kyc,
                                         mode: .verify,
                                         manager: networkManager,
                                         onEmailVerified: { emailVerified = $0; emailVerifiedExpectation.fulfill() },
                                         onUpdate: { updateCallback = $0; updateCallbackExpectation.fulfill() },
                                         onError: nil)
    
    let loadingExpectation = XCTestExpectation(description: "testSuccessVerify_Loading")
    viewModel.loading.sink { [weak viewModel] in
      guard !$0 else { return }
      loading = $0
      viewModel?.verifyCode("123456")
      loadingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let verifiedExpectation = XCTestExpectation(description: "testSuccessVerify_Verified")
    viewModel.emailVerified.sink { [weak viewModel] in
      viewModel?.complete()
      verifiedExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.sendCode()
    
    let expectations = [
      emailVerifiedExpectation,
      loadingExpectation,
      verifiedExpectation,
      updateCallbackExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(loading)
    XCTAssertEqual(viewModel.mode, emailVerified)
    XCTAssertEqual(updateCallback?.event.action, .emailVerified)
  }
  
  func testFailureSendCode() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testFailureSendCode_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    
    let viewModel = VerifyEmailViewModel(email: "test@gmail.com",
                                         flow: .kyc,
                                         mode: .verify,
                                         manager: networkManager,
                                         onEmailVerified: { _ in },
                                         onUpdate: nil,
                                         onError: { errorCallback = $0; errorCallbackExpectation.fulfill() })
    
    let errorExpectation = XCTestExpectation(description: "testFailureSendCode_Error")
    viewModel.error.sink {
      error = $0.error
      errorExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken("")
    viewModel.sendCode()
    
    let expectations = [
      errorExpectation,
      errorCallbackExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
  func testFailureVerifyCode() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testFailureVerifyCode_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    
    let viewModel = VerifyEmailViewModel(email: "test@gmail.com",
                                         flow: .kyc,
                                         mode: .verify,
                                         manager: networkManager,
                                         onEmailVerified: { _ in },
                                         onUpdate: nil,
                                         onError: { errorCallback = $0; errorCallbackExpectation.fulfill() })
    
    let errorExpectation = XCTestExpectation(description: "testFailureVerifyCode_Error")
    viewModel.error.sink {
      error = $0.error
      errorExpectation.fulfill()
    }.store(in: &subscriptions)
    
    viewModel.loading.sink { [weak viewModel] in
      guard !$0 else { return }
      TLManager.shared.setToken("")
      viewModel?.verifyCode("123456")
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.sendCode()
    
    let expectations = [
      errorExpectation,
      errorCallbackExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
}
