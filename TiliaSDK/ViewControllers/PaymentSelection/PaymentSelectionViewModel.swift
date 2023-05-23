//
//  PaymentSelectionViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.05.2023.
//

import Foundation
import Combine

protocol PaymentSelectionViewModelInputProtocol {
  func checkIsTosRequired()
  func complete(isFromCloseAction: Bool)
}

protocol PaymentSelectionViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<ErrorWithBoolModel, Never> { get }
  var needToAcceptTos: PassthroughSubject<Void, Never> { get }
  var content: PassthroughSubject<Void, Never> { get }
  var dismiss: PassthroughSubject<Void, Never> { get }
}

protocol PaymentSelectionDataStore {
  var manager: NetworkManager { get }
  var onTosComplete: (TLCompleteCallback) -> Void { get }
  var onReload: () -> Void { get }
  var onError: ((TLErrorCallback) -> Void)? { get }
}

protocol PaymentSelectionViewModelProtocol: PaymentSelectionViewModelInputProtocol, PaymentSelectionViewModelOutputProtocol { }

final class PaymentSelectionViewModel: PaymentSelectionViewModelProtocol, PaymentSelectionDataStore {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<ErrorWithBoolModel, Never>()
  let needToAcceptTos = PassthroughSubject<Void, Never>()
  let content = PassthroughSubject<Void, Never>()
  let dismiss = PassthroughSubject<Void, Never>()
  
  let manager: NetworkManager
  private(set) lazy var onTosComplete: (TLCompleteCallback) -> Void = { [weak self] in
    guard let self = self else { return }
    if $0.state == .completed {
      self.getPaymentMethods()
    } else {
      self.dismiss.send()
    }
    self.onComplete?($0)
  }
  private(set) lazy var onReload: () -> Void = { [weak self] in
    self?.getPaymentMethods()
  }
  let onError: ((TLErrorCallback) -> Void)?
  
  private let onComplete: ((TLCompleteCallback) -> Void)?
  private let onUpdate: ((TLUpdateCallback) -> Void)?
  
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
          self.getPaymentMethods()
        }
      case .failure(let error):
        self.loading.send(false)
        self.didFail(with: .init(error: error, value: true))
      }
    }
  }
  
  func complete(isFromCloseAction: Bool) {
//    let isCompleted = successfulPayment.value
//    let event = TLEvent(flow: .paymentSelection,
//                        action: isFromCloseAction ? .closedByUser : isCompleted ? .completed : .cancelledByUser)
//    let model = TLCompleteCallback(event: event,
//                                   state: isFromCloseAction ? .error : isCompleted ? .completed : .cancelled)
//    onComplete?(model)
  }
  
}

// MARK: - Private Methods

private extension PaymentSelectionViewModel {
  
  func getPaymentMethods() {
    loading.send(true)
    manager.getUserBalance { [weak self] result in
      guard let self = self else { return }
      self.loading.send(false)
      switch result {
      case .success(let model):
        print(model)
      case .failure(let error):
        self.didFail(with: .init(error: error, value: true))
      }
    }
  }
  
  func didFail(with error: ErrorWithBoolModel) {
    self.error.send(error)
    let event = TLEvent(flow: .paymentSelection, action: .error)
    let model = TLErrorCallback(event: event,
                                error: L.errorPaymentSelectionTitle,
                                message: error.error.localizedDescription)
    onError?(model)
  }
  
}
