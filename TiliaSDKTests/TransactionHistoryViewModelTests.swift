//
//  TransactionHistoryViewModelTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 17.10.2022.
//

import XCTest
import Combine
@testable import TiliaSDK

final class TransactionHistoryViewModelTests: XCTestCase {
  
  var subscriptions: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    subscriptions = []
  }
  
  func testSuccessCheckIsTosRequired() {
    var loading: Bool?
    var needToAcceptTos: Void?
    var completeCallback: TLCompleteCallback?
    var content: Void?
    
    let completeCallbackExpectation = XCTestExpectation(description: "testSuccessCheckIsTosRequired_CompleteCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = TransactionHistoryViewModel(manager: networkManager,
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
    
    let contentExpectation = XCTestExpectation(description: "testSuccessCheckIsTosRequired_Content")
    viewModel.content.sink {
      content = $0
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
    XCTAssertNotNil(content)
  }
  
  func testErrorCheckIsTosRequired() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testErrorCheckIsTosRequired_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let viewModel = TransactionHistoryViewModel(manager: networkManager,
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
    
    let expectations = [
      errorExpectation,
      errorCallbackExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
  func testSuccessLoadTransactions() {
    var loading: Bool?
    var completeCallback: TLCompleteCallback?
    var content: TransactionHistoryChildContent?
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let completeCallbackExpectation = XCTestExpectation(description: "testSuccessLoadTransactions_CompleteCallback")
    let parentViewModel = TransactionHistoryViewModel(manager: networkManager,
                                                      onUpdate: nil,
                                                      onComplete: { completeCallback = $0; completeCallbackExpectation.fulfill() },
                                                      onError: nil)
    let childViewModel = TransactionHistoryChildViewModel(manager: networkManager,
                                                          sectionType: .pending,
                                                          delegate: parentViewModel)
    
    let loadingExpectation = XCTestExpectation(description: "testSuccessLoadTransactions_Loading")
    childViewModel.loading.sink {
      loading = $0
      loadingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let contentExpectation = XCTestExpectation(description: "testSuccessLoadTransactions_Content")
    childViewModel.content.sink { [weak parentViewModel] in
      content = $0
      contentExpectation.fulfill()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        parentViewModel?.complete(isFromCloseAction: false)
      }
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    childViewModel.loadTransactions()
    
    let expectations = [
      loadingExpectation,
      completeCallbackExpectation,
      contentExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(loading)
    XCTAssertEqual(completeCallback?.state, .completed)
    XCTAssertEqual(content?.models.isEmpty, false)
    XCTAssertEqual(content?.needReload, true)
  }
  
  func testErrorLoadTransactions() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let errorCallbackExpectation = XCTestExpectation(description: "testErrorLoadTransactions_ErrorCallback")
    let parentViewModel = TransactionHistoryViewModel(manager: networkManager,
                                                      onUpdate: nil,
                                                      onComplete: nil,
                                                      onError: { errorCallback = $0; errorCallbackExpectation.fulfill() })
    let childViewModel = TransactionHistoryChildViewModel(manager: networkManager,
                                                          sectionType: .pending,
                                                          delegate: parentViewModel)
    
    let errorExpectation = XCTestExpectation(description: "testErrorLoadTransactions_Error")
    parentViewModel.error.sink {
      error = $0.error
      errorExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken("")
    childViewModel.loadTransactions()
    
    let expectations = [
      errorExpectation,
      errorCallbackExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
  func testSuccessLoadMoreTransactions() {
    var content: TransactionHistoryChildContent?
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let parentViewModel = TransactionHistoryViewModel(manager: networkManager,
                                                      onUpdate: nil,
                                                      onComplete: nil,
                                                      onError: nil)
    let childViewModel = TransactionHistoryChildViewModel(manager: networkManager,
                                                          sectionType: .pending,
                                                          delegate: parentViewModel)
    
    let contentExpectation = XCTestExpectation(description: "testSuccessLoadMoreTransactions_Content")
    childViewModel.content.sink {
      content = $0
      contentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    childViewModel.loadMoreTransactionsIfNeeded()
    
    wait(for: [contentExpectation], timeout: 2)
    XCTAssertEqual(content?.models.isEmpty, false)
    XCTAssertEqual(content?.needReload, false)
  }
  
  func testErrorLoadMoreTransactions() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let errorCallbackExpectation = XCTestExpectation(description: "testErrorLoadMoreTransactions_ErrorCallback")
    let parentViewModel = TransactionHistoryViewModel(manager: networkManager,
                                                      onUpdate: nil,
                                                      onComplete: nil,
                                                      onError: { errorCallback = $0; errorCallbackExpectation.fulfill() })
    let childViewModel = TransactionHistoryChildViewModel(manager: networkManager,
                                                          sectionType: .pending,
                                                          delegate: parentViewModel)
    
    let errorExpectation = XCTestExpectation(description: "testErrorLoadMoreTransactions_Error")
    parentViewModel.error.sink {
      error = $0.error
      errorExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken("")
    childViewModel.loadMoreTransactionsIfNeeded()
    
    let expectations = [
      errorExpectation,
      errorCallbackExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
  func testSuccessSelectTransaction() {
    var selectedTransaction: TransactionDetailsModel?
    var content: TransactionHistoryChildContent?
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let parentViewModel = TransactionHistoryViewModel(manager: networkManager,
                                                      onUpdate: nil,
                                                      onComplete: nil,
                                                      onError: nil)
    let childViewModel = TransactionHistoryChildViewModel(manager: networkManager,
                                                          sectionType: .pending,
                                                          delegate: parentViewModel)
    
    childViewModel.content.sink { [weak childViewModel] in
      content = $0
      childViewModel?.selectTransaction(at: 0)
    }.store(in: &subscriptions)
    
    let contentExpectation = XCTestExpectation(description: "testSuccessSelectTransaction_SelectTransaction")
    parentViewModel.selectTransaction.sink { [weak parentViewModel] in
      selectedTransaction = parentViewModel?.selectedTransaction
      contentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    childViewModel.loadTransactions()
    
    wait(for: [contentExpectation], timeout: 2)
    XCTAssertNotNil(selectedTransaction)
    XCTAssertNotNil(content)
  }
  
}
