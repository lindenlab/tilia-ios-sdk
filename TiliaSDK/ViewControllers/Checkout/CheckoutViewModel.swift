//
//  CheckoutViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import Foundation
import Combine

typealias CheckoutContent = (invoice: InvoiceModel, balance: BalanceModel, invoiceDetails: InvoiceDetailsModel)

protocol CheckoutViewModelInputProtocol {
  func checkIsTosRequired()
  func proceedCheckout()
}

protocol CheckoutViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
  var needToAcceptTos: PassthroughSubject<Void, Never> { get }
  var content: CurrentValueSubject<CheckoutContent?, Never> { get }
  var successfulPayment: PassthroughSubject<Void, Never> { get }
}

protocol CheckoutViewModelProtocol: CheckoutViewModelInputProtocol, CheckoutViewModelOutputProtocol { }

final class CheckoutViewModel: CheckoutViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<Error, Never>()
  let needToAcceptTos = PassthroughSubject<Void, Never>()
  let content = CurrentValueSubject<CheckoutContent?, Never>(nil)
  let successfulPayment = PassthroughSubject<Void, Never>()
  
  private let invoiceId: String
  private let manager = TLManager.shared
  
  init(invoiceId: String) {
    self.invoiceId = invoiceId
  }
  
  func checkIsTosRequired() {
    loading.send(true)
    manager.getTosRequiredForUser { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let isTosSigned):
        if !isTosSigned {
          self.needToAcceptTos.send(())
        } else {
          self.proceedCheckout()
        }
      case .failure(let error):
        self.setFailed(with: error)
      }
    }
  }
  
  func proceedCheckout() {
    manager.getInvoiceDetails(with: invoiceId) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        self.createInvoice(with: model)
      case .failure(let error):
        self.setFailed(with: error)
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
        self.successfulPayment.send(())
      case .failure(let error):
        self.setFailed(with: error)
      }
    }
  }
  
}

// MARK: - Private Methods

private extension CheckoutViewModel {
  
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
    manager.getBalanceByCurrencyCode(invoiceDetails.currency) { result in
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
        self.error.send(error)
      }
      self.loading.send(false)
    }
  }
  
  func setFailed(with error: Error) {
    loading.send(false)
    self.error.send(error)
  }
  
}
