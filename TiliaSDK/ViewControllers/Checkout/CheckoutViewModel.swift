//
//  CheckoutViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import Foundation
import Combine

typealias CheckoutContent = (invoice: InvoiceModel, balance: BalanceModel, invoiceDetails: InvoiceDetailsModel)
typealias CheckoutError = (error: Error, needToShowCancelButton: Bool)

protocol CheckoutViewModelInputProtocol {
  func checkIsTosRequired()
  func payInvoice()
  func didDismiss(isFromCloseAction: Bool)
}

protocol CheckoutViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<CheckoutError, Never> { get }
  var needToAcceptTos: PassthroughSubject<Void, Never> { get }
  var content: CurrentValueSubject<CheckoutContent?, Never> { get }
  var successfulPayment: CurrentValueSubject<Bool, Never> { get }
  var dismiss: PassthroughSubject<Void, Never> { get }
}

protocol CheckoutDataStore {
  var manager: NetworkManager { get }
  var onTosComplete: (TLCompleteCallback) -> Void { get }
  var onTosError: ((TLErrorCallback) -> Void)? { get }
}

protocol CheckoutViewModelProtocol: CheckoutViewModelInputProtocol, CheckoutViewModelOutputProtocol { }

final class CheckoutViewModel: CheckoutViewModelProtocol, CheckoutDataStore {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<CheckoutError, Never>()
  let needToAcceptTos = PassthroughSubject<Void, Never>()
  let content = CurrentValueSubject<CheckoutContent?, Never>(nil)
  let successfulPayment = CurrentValueSubject<Bool, Never>(false)
  let dismiss = PassthroughSubject<Void, Never>()
  
  let manager: NetworkManager
  private(set) lazy var onTosComplete: (TLCompleteCallback) -> Void = { [weak self] in
    guard let self = self else { return }
    if $0.state == .completed {
      self.proceedCheckout()
    } else {
      self.dismiss.send(())
    }
    self.onComplete?($0)
  }
  var onTosError: ((TLErrorCallback) -> Void)? {
    return onError
  }
  
  private let onComplete: ((TLCompleteCallback) -> Void)?
  private let onError: ((TLErrorCallback) -> Void)?
  private let onUpdate: ((TLUpdateCallback) -> Void)?
  private let invoiceId: String
  
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
          self.needToAcceptTos.send(())
        } else {
          self.proceedCheckout()
        }
      case .failure(let error):
        self.loading.send(false)
        self.didFail(with: (error, true))
      }
    }
  }
  
  func payInvoice() {
    guard let content = content.value else { return }
    let id = content.invoice.invoiceId
    let isEscrow = content.invoiceDetails.isEscrow
    loading.send(true)
    manager.payInvoice(withId: id, isEscrow: isEscrow) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success:
        self.successfulPayment.send(true)
        self.onUpdate?(TLUpdateCallback(event: TLEvent(flow: .checkout, action: .paymentProcessed),
                                        message: L.paymentProcessed))
      case .failure(let error):
        self.didFail(with: (error, false))
      }
      self.loading.send(false)
    }
  }
  
  func didDismiss(isFromCloseAction: Bool) {
    let isCompleted = successfulPayment.value
    let event = TLEvent(flow: .checkout,
                        action: isCompleted ? .completed : .cancelledByUser)
    let model = TLCompleteCallback(event: event,
                                   state: isFromCloseAction ? .error : isCompleted ? .completed : .cancelled)
    onComplete?(model)
  }
  
}

// MARK: - Private Methods

private extension CheckoutViewModel {
  
  func proceedCheckout() {
    manager.getInvoiceDetails(with: invoiceId) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        self.createInvoice(with: model)
      case .failure(let error):
        self.loading.send(false)
        self.didFail(with: (error, true))
      }
    }
  }
  
  func createInvoice(with invoiceDetails: InvoiceDetailsModel) {
    var serverError: Error?
    var invoice: InvoiceModel?
    var balance: BalanceModel?
    let dispatchGroup = DispatchGroup()
    
    dispatchGroup.enter()
    manager.createInvoice(withId: invoiceId, isEscrow: invoiceDetails.isEscrow) { result in
      dispatchGroup.leave()
      switch result {
      case .success(let model):
        invoice = model
      case .failure(let error):
        serverError = error
      }
    }
    
    dispatchGroup.enter()
    manager.getUserBalanceByCurrencyCode(invoiceDetails.currency) { result in
      dispatchGroup.leave()
      switch result {
      case .success(let model):
        balance = model
      case .failure(let error):
        serverError = error
      }
    }
    
    dispatchGroup.notify(queue: .main) {
      if let invoice = invoice, let balance = balance {
        self.content.send((invoice, balance, invoiceDetails))
      } else if let error = serverError {
        self.didFail(with: (error, true))
      }
      self.loading.send(false)
    }
  }
  
  func didFail(with error: CheckoutError) {
    self.error.send(error)
    let event = TLEvent(flow: .checkout, action: .error)
    let model = TLErrorCallback(event: event,
                                error: L.errorPaymentTitle,
                                message: error.error.localizedDescription)
    onError?(model)
  }
  
}
