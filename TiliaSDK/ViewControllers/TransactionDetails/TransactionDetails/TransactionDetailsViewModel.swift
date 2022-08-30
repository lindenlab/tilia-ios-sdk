//
//  TransactionDetailsViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import Combine

protocol TransactionDetailsViewModelInputProtocol {
  func checkIsTosRequired()
  func complete(isFromCloseAction: Bool)
}

protocol TransactionDetailsViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<ErrorWithBoolModel, Never> { get }
  var needToAcceptTos: PassthroughSubject<Void, Never> { get }
  var content: PassthroughSubject<TransactionDetailsModel, Never> { get }
  var dismiss: PassthroughSubject<Void, Never> { get }
}

protocol TransactionDetailsDataStore {
  var manager: NetworkManager { get }
  var onUpdate: ((TLUpdateCallback) -> Void)? { get }
  var onTosComplete: (TLCompleteCallback) -> Void { get }
  var onError: ((TLErrorCallback) -> Void)? { get }
}

protocol TransactionDetailsViewModelProtocol: TransactionDetailsViewModelInputProtocol, TransactionDetailsViewModelOutputProtocol { }

final class TransactionDetailsViewModel: TransactionDetailsViewModelProtocol, TransactionDetailsDataStore {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<ErrorWithBoolModel, Never>()
  let needToAcceptTos = PassthroughSubject<Void, Never>()
  let content = PassthroughSubject<TransactionDetailsModel, Never>()
  let dismiss = PassthroughSubject<Void, Never>()
  
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
  
  private let invoiceId: String
  private let onComplete: ((TLCompleteCallback) -> Void)?
  private var isLoaded = false
  
  init(invoiceId: String,
       manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    self.invoiceId = invoiceId
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
          self.getTransactionDetails()
        }
      case .failure(let error):
        self.didFail(with: .init(error: error, value: true))
        self.loading.send(false)
      }
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
  
  func getTransactionDetails() {
    manager.getTransactionDetails(with: invoiceId) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        self.content.send(model)
        self.isLoaded = true
      case .failure(let error):
        self.didFail(with: .init(error: error, value: true))
      }
      self.loading.send(false)
    }
  }
  
  func didFail(with error: ErrorWithBoolModel) {
    self.error.send(error)
    let event = TLEvent(flow: .transactionDetails, action: .error)
    let model = TLErrorCallback(event: event,
                                error: L.errorTransactionDetailsTitle,
                                message: error.error.localizedDescription)
    onError?(model)
  }
  
}
