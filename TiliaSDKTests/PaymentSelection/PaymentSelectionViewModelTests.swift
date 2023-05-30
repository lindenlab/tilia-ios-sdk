//
//  PaymentSelectionViewModelTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 25.05.2023.
//

import XCTest
import Combine
@testable import TiliaSDK

final class PaymentSelectionViewModelTests: XCTestCase {
  
  var subscriptions: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    subscriptions = []
  }
  
  func testSuccessSelectOnePaymentMethod() {
    var loading: Bool?
    var needToAcceptTos: Void?
    var completeCallback: TLCompleteCallback?
    var selectIndex: Int?
    var deselectIndex: Int?
    
    let completeCallbackExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_CompleteCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = PaymentSelectionViewModel(manager: networkManager,
                                              amount: nil,
                                              currencyCode: nil,
                                              onUpdate: nil,
                                              onComplete: { completeCallback = $0; completeCallbackExpectation.fulfill() },
                                              onError: nil)
    
    let loadingExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_Loading")
    viewModel.loading.sink {
      loading = $0
      loadingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let needToAcceptTosExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_NeedToAcceptTos")
    viewModel.needToAcceptTos.sink { [weak viewModel] in
      needToAcceptTos = $0
      needToAcceptTosExpectation.fulfill()
      let event = TLCompleteCallback(event: TLEvent(flow: .tos, action: .completed),
                                     state: .completed)
      viewModel?.onTosComplete(event)
    }.store(in: &subscriptions)
    
    let contentExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_Content")
    viewModel.content.sink { [weak viewModel] _ in
      viewModel?.selectPaymentMethod(at: .init(row: 0, section: 0))
      contentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let selectIndexExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_SelectIndex")
    viewModel.selectIndex.sink {
      selectIndex = $0.row
      selectIndexExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let deselectIndexExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_DeselectIndex")
    viewModel.deselectIndex.sink {
      deselectIndex = $0.row
      deselectIndexExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let paymentButtonIsEnabledExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_PaymentButtonIsEnabled")
    viewModel.paymentButtonIsEnabled.sink { [weak viewModel] in
      guard $0.isEnabled else { return }
      if selectIndex == 0 {
        viewModel?.selectPaymentMethod(at: .init(row: 1, section: 0))
      } else if selectIndex == 1 {
        viewModel?.useSelectedPaymentMethod()
        paymentButtonIsEnabledExpectation.fulfill()
      }
    }.store(in: &subscriptions)
    
    let dismissExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_Dismiss")
    viewModel.dismiss.sink { [weak viewModel] in
      viewModel?.complete(isFromCloseAction: false)
      dismissExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.checkIsTosRequired()
    
    let expectations = [
      completeCallbackExpectation,
      needToAcceptTosExpectation,
      loadingExpectation,
      contentExpectation,
      selectIndexExpectation,
      deselectIndexExpectation,
      paymentButtonIsEnabledExpectation,
      dismissExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(loading)
    XCTAssertNotNil(needToAcceptTos)
    XCTAssertEqual(completeCallback?.state, .completed)
    XCTAssertNotNil(completeCallback?.data)
    XCTAssertEqual(selectIndex, 1)
    XCTAssertEqual(deselectIndex, 0)
  }
  
  func testSuccessSelectTwoPaymentMethod() {
    var loading: Bool?
    var needToAcceptTos: Void?
    var completeCallback: TLCompleteCallback?
    var selectIndex: Int?
    var paymentMethodsAreEnabled: Bool?
    
    let completeCallbackExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_CompleteCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = PaymentSelectionViewModel(manager: networkManager,
                                              amount: 100000,
                                              currencyCode: nil,
                                              onUpdate: nil,
                                              onComplete: { completeCallback = $0; completeCallbackExpectation.fulfill() },
                                              onError: nil)
    
    let loadingExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_Loading")
    viewModel.loading.sink {
      loading = $0
      loadingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let needToAcceptTosExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_NeedToAcceptTos")
    viewModel.needToAcceptTos.sink { [weak viewModel] in
      needToAcceptTos = $0
      needToAcceptTosExpectation.fulfill()
      let event = TLCompleteCallback(event: TLEvent(flow: .tos, action: .completed),
                                     state: .completed)
      viewModel?.onTosComplete(event)
    }.store(in: &subscriptions)
    
    let contentExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_Content")
    viewModel.content.sink { [weak viewModel] _ in
      viewModel?.selectPaymentMethod(at: .init(row: 0, section: 0), isSelected: true)
      contentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let selectIndexExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_SelectIndex")
    viewModel.selectIndex.sink {
      selectIndex = $0.row
      selectIndexExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let paymentMethodsAreEnabledExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_PaymentMethodsAreEnabled")
    viewModel.paymentMethodsAreEnabled.sink {
      paymentMethodsAreEnabled = $0.isEnabled
      paymentMethodsAreEnabledExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let paymentButtonIsEnabledExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_PaymentButtonIsEnabled")
    viewModel.paymentButtonIsEnabled.sink { [weak viewModel] _ in
      if selectIndex == 0 {
        viewModel?.selectPaymentMethod(at: .init(row: 1, section: 0))
      } else if selectIndex == 1 {
        viewModel?.useSelectedPaymentMethod()
        paymentButtonIsEnabledExpectation.fulfill()
      }
    }.store(in: &subscriptions)
    
    let dismissExpectation = XCTestExpectation(description: "testSuccessSelectOnePaymentMethod_Dismiss")
    viewModel.dismiss.sink { [weak viewModel] in
      viewModel?.complete(isFromCloseAction: false)
      dismissExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.checkIsTosRequired()
    
    let expectations = [
      completeCallbackExpectation,
      needToAcceptTosExpectation,
      loadingExpectation,
      contentExpectation,
      selectIndexExpectation,
      paymentButtonIsEnabledExpectation,
      paymentMethodsAreEnabledExpectation,
      dismissExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(loading)
    XCTAssertNotNil(needToAcceptTos)
    XCTAssertEqual(completeCallback?.state, .completed)
    XCTAssertNotNil(completeCallback?.data)
    XCTAssertEqual(selectIndex, 1)
    XCTAssertEqual(paymentMethodsAreEnabled, true)
  }
  
  func testSuccessRenamePaymentMethod() {
    var updateCallback: TLUpdateCallback?
    var count = 0
    
    let updateCallbackExpectation = XCTestExpectation(description: "testSuccessRenamePaymentMethod_UpdateCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = PaymentSelectionViewModel(manager: networkManager,
                                              amount: nil,
                                              currencyCode: nil,
                                              onUpdate: { updateCallback = $0; updateCallbackExpectation.fulfill() },
                                              onComplete: nil,
                                              onError: nil)
    
    let contentExpectation = XCTestExpectation(description: "testSuccessRenamePaymentMethod_Content")
    viewModel.content.sink { [weak viewModel] _ in
      count += 1
      if count == 1 {
        viewModel?.renamePaymentMethod(at: 1, with: "newName")
      } else if count == 2 {
        contentExpectation.fulfill()
      }
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    let event = TLCompleteCallback(event: TLEvent(flow: .tos, action: .completed),
                                   state: .completed)
    viewModel.onTosComplete(event)
    
    let expectations = [
      updateCallbackExpectation,
      contentExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertEqual(count, 2)
    XCTAssertEqual(updateCallback?.event.action, .paymentMethodRenamed)
    XCTAssertEqual(updateCallback?.event.flow, .paymentSelection)
  }
  
  func testSuccessDeletePaymentMethod() {
    var updateCallback: TLUpdateCallback?
    var count = 0
    
    let updateCallbackExpectation = XCTestExpectation(description: "testSuccessRenamePaymentMethod_UpdateCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = PaymentSelectionViewModel(manager: networkManager,
                                              amount: nil,
                                              currencyCode: nil,
                                              onUpdate: { updateCallback = $0; updateCallbackExpectation.fulfill() },
                                              onComplete: nil,
                                              onError: nil)
    
    let contentExpectation = XCTestExpectation(description: "testSuccessRenamePaymentMethod_Content")
    viewModel.content.sink { [weak viewModel] _ in
      count += 1
      if count == 1 {
        viewModel?.removePaymentMethod(at: 1)
      } else if count == 2 {
        contentExpectation.fulfill()
      }
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    let event = TLCompleteCallback(event: TLEvent(flow: .tos, action: .completed),
                                   state: .completed)
    viewModel.onTosComplete(event)
    
    let expectations = [
      updateCallbackExpectation,
      contentExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertEqual(count, 2)
    XCTAssertEqual(updateCallback?.event.action, .paymentMethodDeleted)
    XCTAssertEqual(updateCallback?.event.flow, .paymentSelection)
  }
  
  func testErrorLoad() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testErrorLoad_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = PaymentSelectionViewModel(manager: networkManager,
                                              amount: nil,
                                              currencyCode: nil,
                                              onUpdate: nil,
                                              onComplete: nil,
                                              onError: { errorCallback = $0; errorCallbackExpectation.fulfill() })
    
    let errorExpectation = XCTestExpectation(description: "testErrorLoad_Error")
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
  
}
