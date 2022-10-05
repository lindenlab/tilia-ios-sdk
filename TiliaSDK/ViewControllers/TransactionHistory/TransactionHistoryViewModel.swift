//
//  TransactionHistoryViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.09.2022.
//

import Combine

protocol TransactionHistoryViewModelInputProtocol {
  func checkIsTosRequired()
  func complete(isFromCloseAction: Bool)
}

protocol TransactionHistoryViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<ErrorWithBoolModel, Never> { get }
  var needToAcceptTos: PassthroughSubject<Void, Never> { get }
  var dismiss: PassthroughSubject<Void, Never> { get }
  var content: PassthroughSubject<Void, Never> { get }
  var selectTransaction: PassthroughSubject<Void, Never> { get }
}

protocol TransactionHistoryDataStore {
  var selectedTransaction: TransactionDetailsModel? { get }
  var manager: NetworkManager { get }
  var onUpdate: ((TLUpdateCallback) -> Void)? { get }
  var onTosComplete: (TLCompleteCallback) -> Void { get }
  var onComplete: ((TLCompleteCallback) -> Void)? { get }
  var onError: ((TLErrorCallback) -> Void)? { get }
}

protocol TransactionHistoryViewModelProtocol: TransactionHistoryViewModelInputProtocol, TransactionHistoryViewModelOutputProtocol { }

final class TransactionHistoryViewModel: TransactionHistoryViewModelProtocol, TransactionHistoryDataStore {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<ErrorWithBoolModel, Never>()
  let needToAcceptTos = PassthroughSubject<Void, Never>()
  let dismiss = PassthroughSubject<Void, Never>()
  let content = PassthroughSubject<Void, Never>()
  let selectTransaction = PassthroughSubject<Void, Never>()
  
  private(set) var selectedTransaction: TransactionDetailsModel?
  let manager: NetworkManager
  let onUpdate: ((TLUpdateCallback) -> Void)?
  private(set) lazy var onTosComplete: (TLCompleteCallback) -> Void = { [weak self] in
    guard let self = self else { return }
    if $0.state == .completed {
      self.didLoad()
    } else {
      self.dismiss.send()
    }
    self.onComplete?($0)
  }
  let onComplete: ((TLCompleteCallback) -> Void)?
  let onError: ((TLErrorCallback) -> Void)?
  
  private var isLoaded = false
  
  init(manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    self.manager = manager
    self.onUpdate = onUpdate
    self.onComplete = onComplete
    self.onError = onError
  }
  
  func checkIsTosRequired() {
    loading.send(true)
    manager.getTosRequiredForUser { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        if !model.isTosSigned {
          self.needToAcceptTos.send()
        } else {
          self.didLoad()
        }
      case .failure(let error):
        self.didFail(with: .init(error: error, value: true))
        self.loading.send(false)
      }
    }
  }
  
  func complete(isFromCloseAction: Bool) {
    let event = TLEvent(flow: .transactionHistory,
                        action: isFromCloseAction ? .closedByUser : isLoaded ? .completed : .cancelledByUser)
    let model = TLCompleteCallback(event: event,
                                   state: isFromCloseAction ? .error : isLoaded ? .completed : .cancelled)
    onComplete?(model)
  }
  
}

// MARK: - TransactionHistoryChildViewModelDelegate

extension TransactionHistoryViewModel: TransactionHistoryChildViewModelDelegate {
  
  func transactionHistoryChildViewModelDidLoad() {
    guard !isLoaded else { return }
    isLoaded = true
  }
  
  func transactionHistoryChildViewModel(didFailWithError error: Error) {
    didFail(with: .init(error: error, value: false))
  }
  
  func transactionHistoryChildViewModel(didSelectTransaction transaction: TransactionDetailsModel) {
    self.selectedTransaction = transaction
    selectTransaction.send()
    self.selectedTransaction = nil
  }
  
}

// MARK: - Private Methods

private extension TransactionHistoryViewModel {
  
  func didLoad() {
    content.send()
    loading.send(false)
  }
  
  func didFail(with error: ErrorWithBoolModel) {
    self.error.send(error)
    let event = TLEvent(flow: .transactionHistory, action: .error)
    let model = TLErrorCallback(event: event,
                                error: L.errorTransactionHistoryTitle,
                                message: error.error.localizedDescription)
    onError?(model)
  }
  
}
