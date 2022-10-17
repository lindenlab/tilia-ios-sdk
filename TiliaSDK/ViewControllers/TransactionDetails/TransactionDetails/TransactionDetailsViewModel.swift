//
//  TransactionDetailsViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import Combine

enum TransactionDetailsMode {
  case id(String)
  case transaction(TransactionDetailsModel)
  
  var id: String {
    switch self {
    case let .id(id): return id
    case let .transaction(model): return model.id
    }
  }
}

protocol TransactionDetailsViewModelInputProtocol {
  func checkIsTosRequired()
  func complete(isFromCloseAction: Bool)
}

protocol TransactionDetailsViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
  var needToAcceptTos: PassthroughSubject<Void, Never> { get }
  var dismiss: PassthroughSubject<Void, Never> { get }
  var content: PassthroughSubject<TransactionDetailsModel, Never> { get }
}

protocol TransactionDetailsDataStore {
  var transactionId: String { get }
  var manager: NetworkManager { get }
  var onUpdate: ((TLUpdateCallback) -> Void)? { get }
  var onTosComplete: (TLCompleteCallback) -> Void { get }
  var onError: ((TLErrorCallback) -> Void)? { get }
}

protocol TransactionDetailsViewModelProtocol: TransactionDetailsViewModelInputProtocol, TransactionDetailsViewModelOutputProtocol { }

final class TransactionDetailsViewModel: TransactionDetailsViewModelProtocol, TransactionDetailsDataStore {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<Error, Never>()
  let needToAcceptTos = PassthroughSubject<Void, Never>()
  let dismiss = PassthroughSubject<Void, Never>()
  let content = PassthroughSubject<TransactionDetailsModel, Never>()
  
  var transactionId: String { return mode.id }
  let manager: NetworkManager
  let onUpdate: ((TLUpdateCallback) -> Void)?
  private(set) lazy var onTosComplete: (TLCompleteCallback) -> Void = { [weak self] in
    guard let self = self else { return }
    if $0.state == .completed {
      self.getTransactionDetails()
    } else {
      self.dismiss.send()
    }
    self.onComplete?($0)
  }
  let onError: ((TLErrorCallback) -> Void)?
  
  private let onComplete: ((TLCompleteCallback) -> Void)?
  private let mode: TransactionDetailsMode
  private var isLoaded = false
  
  init(mode: TransactionDetailsMode,
       manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    self.mode = mode
    self.manager = manager
    self.onUpdate = onUpdate
    self.onComplete = onComplete
    self.onError = onError
  }
  
  func checkIsTosRequired() {
    switch mode {
    case let .transaction(model):
      isLoaded = true
      content.send(model)
    case .id:
      loadContent()
    }
    
  }
  
  func complete(isFromCloseAction: Bool) {
    let event = TLEvent(flow: .transactionDetails,
                        action: isFromCloseAction ? .closedByUser : isLoaded ? .completed : .cancelledByUser)
    let model = TLCompleteCallback(event: event,
                                   state: isFromCloseAction ? .error : isLoaded ? .completed : .cancelled)
    onComplete?(model)
  }
  
}

// MARK: - Private Methods

private extension TransactionDetailsViewModel {
  
  func loadContent() {
    loading.send(true)
    manager.getTosRequiredForUser { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        if !model.isTosSigned {
          self.needToAcceptTos.send()
        } else {
          self.getTransactionDetails()
        }
      case .failure(let error):
        self.didFail(with: error)
        self.loading.send(false)
      }
    }
  }
  
  func getTransactionDetails() {
    manager.getTransactionDetails(with: transactionId) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        self.isLoaded = true
        self.content.send(model)
      case .failure(let error):
        self.didFail(with: error)
      }
      self.loading.send(false)
    }
  }
  
  func didFail(with error: Error) {
    self.error.send(error)
    let event = TLEvent(flow: .transactionDetails, action: .error)
    let model = TLErrorCallback(event: event,
                                error: L.errorTransactionDetailsTitle,
                                message: error.localizedDescription)
    onError?(model)
  }
  
}
