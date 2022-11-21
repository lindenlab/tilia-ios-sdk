//
//  CheckoutViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import Foundation
import Combine

typealias CheckoutContent = (invoiceInfo: InvoiceInfoModel, walletBalance: BalanceModel, paymentMethods: [CheckoutPaymentMethodModel], isVirtual: Bool)

protocol CheckoutViewModelInputProtocol {
  func checkIsTosRequired()
  func payInvoice()
  func complete(isFromCloseAction: Bool)
  func selectPaymentMethod(at index: Int)
}

protocol CheckoutViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<ErrorWithBoolModel, Never> { get }
  var needToAcceptTos: PassthroughSubject<Void, Never> { get }
  var content: PassthroughSubject<CheckoutContent, Never> { get }
  var successfulPayment: CurrentValueSubject<Bool, Never> { get }
  var dismiss: PassthroughSubject<Void, Never> { get }
  var createInvoiceLoading: PassthroughSubject<Bool, Never> { get }
  var payButtonIsEnabled: PassthroughSubject<Bool, Never> { get }
  var deselectIndex: PassthroughSubject<Int, Never> { get }
  var selectIndex: PassthroughSubject<Int, Never> { get }
  var updateSummary: PassthroughSubject<InvoiceInfoModel, Never> { get }
}

protocol CheckoutDataStore {
  var manager: NetworkManager { get }
  var onTosComplete: (TLCompleteCallback) -> Void { get }
  var onReload: (Bool) -> Void { get }
  var onError: ((TLErrorCallback) -> Void)? { get }
}

protocol CheckoutViewModelProtocol: CheckoutViewModelInputProtocol, CheckoutViewModelOutputProtocol { }

final class CheckoutViewModel: CheckoutViewModelProtocol, CheckoutDataStore {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<ErrorWithBoolModel, Never>()
  let needToAcceptTos = PassthroughSubject<Void, Never>()
  let content = PassthroughSubject<CheckoutContent, Never>()
  let successfulPayment = CurrentValueSubject<Bool, Never>(false)
  let dismiss = PassthroughSubject<Void, Never>()
  let createInvoiceLoading = PassthroughSubject<Bool, Never>()
  let payButtonIsEnabled = PassthroughSubject<Bool, Never>()
  let deselectIndex = PassthroughSubject<Int, Never>()
  let selectIndex = PassthroughSubject<Int, Never>()
  let updateSummary = PassthroughSubject<InvoiceInfoModel, Never>()
  
  let manager: NetworkManager
  private(set) lazy var onTosComplete: (TLCompleteCallback) -> Void = { [weak self] in
    guard let self = self else { return }
    if $0.state == .completed {
      self.getInvoiceDetails()
    } else {
      self.dismiss.send()
    }
    self.onComplete?($0)
  }
  private(set) lazy var onReload: (Bool) -> Void = { [weak self] in
    guard $0 else { return }
    self?.getUserBalance()
  }
  let onError: ((TLErrorCallback) -> Void)?
  
  private let onComplete: ((TLCompleteCallback) -> Void)?
  private let onUpdate: ((TLUpdateCallback) -> Void)?
  private let authorizedInvoiceId: String
  private var invoiceId: String?
  private var balance: BalanceInfoModel?
  private var invoiceInfo: InvoiceInfoModel?
  private var selectedPaymentMethod: CheckoutPaymentMethodModel?
  private var isEscrow: Bool?
  private var isVirtual: Bool?
  
  init(invoiceId: String,
       manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    self.authorizedInvoiceId = invoiceId
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
          self.getInvoiceDetails()
        }
      case .failure(let error):
        self.didFail(with: .init(error: error, value: true))
        self.loading.send(false)
      }
    }
  }
  
  func payInvoice() {
    guard
      let isEscrow = isEscrow,
      let id = invoiceId else { return }
    loading.send(true)
    manager.payInvoice(withId: id, isEscrow: isEscrow) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success:
        self.successfulPayment.send(true)
        self.onUpdate?(TLUpdateCallback(event: TLEvent(flow: .checkout, action: .paymentProcessed),
                                        message: L.paymentProcessed))
      case .failure(let error):
        self.didFail(with: .init(error: error, value: false))
      }
      self.loading.send(false)
    }
  }
  
  func complete(isFromCloseAction: Bool) {
    let isCompleted = successfulPayment.value
    let event = TLEvent(flow: .checkout,
                        action: isFromCloseAction ? .closedByUser : isCompleted ? .completed : .cancelledByUser)
    let model = TLCompleteCallback(event: event,
                                   state: isFromCloseAction ? .error : isCompleted ? .completed : .cancelled)
    onComplete?(model)
  }
  
  func selectPaymentMethod(at index: Int) {
    guard
      let isEscrow = isEscrow,
      let paymentMethods = balance?.paymentMethods,
      selectedPaymentMethod != paymentMethods[index] else { return }
    
    if let deselectIndex = paymentMethods.firstIndex(where: { $0 == selectedPaymentMethod }) {
      self.deselectIndex.send(deselectIndex)
    }
    
    selectedPaymentMethod = paymentMethods[index]
    selectIndex.send(index)
    
    createInvoiceLoading.send(true)
    payButtonIsEnabled.send(false)
    manager.createInvoice(withId: authorizedInvoiceId, isEscrow: isEscrow, paymentMethod: selectedPaymentMethod) { [weak self] result in
      guard let self = self else { return }
      self.createInvoiceLoading.send(false)
      switch result {
      case .success(let model):
        self.invoiceId = model.invoiceId
        self.invoiceInfo = model.info
        self.payButtonIsEnabled.send(true)
        self.updateSummary.send(model.info)
      case .failure(let error):
        self.selectedPaymentMethod = nil
        self.invoiceId = nil
        self.deselectIndex.send(index)
        self.didFail(with: .init(error: error, value: false))
      }
    }
  }
  
}

// MARK: - Private Methods

private extension CheckoutViewModel {
  
  func getInvoiceDetails() {
    var serverError: Error?
    var balance: BalanceInfoModel?
    var invoiceDetails: InvoiceDetailsModel?
    let dispatchGroup = DispatchGroup()
    
    dispatchGroup.enter()
    manager.getInvoiceDetails(with: authorizedInvoiceId) { result in
      dispatchGroup.leave()
      switch result {
      case .success(let model):
        invoiceDetails = model
      case .failure(let error):
        serverError = error
      }
    }
    
    dispatchGroup.enter()
    manager.getUserBalance { result in
      dispatchGroup.leave()
      switch result {
      case .success(let model):
        balance = model
      case .failure(let error):
        serverError = error
      }
    }
    
    dispatchGroup.notify(queue: .main) {
      if let balance = balance, let invoiceDetails = invoiceDetails {
        self.isEscrow = invoiceDetails.isEscrow
        self.isVirtual = invoiceDetails.isVirtual
        self.balance = balance
        if invoiceDetails.isVirtual {
          self.createVirtualInvoice()
        } else {
          self.invoiceInfo = invoiceDetails.info
          self.setContent()
          self.loading.send(false)
        }
      } else if let error = serverError {
        self.didFail(with: .init(error: error, value: true))
        self.loading.send(false)
      }
    }
    
  }
  
  func createVirtualInvoice() {
    guard let isEscrow = isEscrow else { return }
    manager.createInvoice(withId: authorizedInvoiceId, isEscrow: isEscrow, paymentMethod: nil) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        self.invoiceId = model.invoiceId
        self.invoiceInfo = model.info
        self.setContent()
      case .failure(let error):
        self.didFail(with: .init(error: error, value: true))
      }
      self.loading.send(false)
    }
  }
  
  func getUserBalance() {
    selectedPaymentMethod = nil
    loading.send(true)
    manager.getUserBalance { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        self.balance = model
        self.setContent()
      case .failure(let error):
        self.didFail(with: .init(error: error, value: true))
      }
      self.loading.send(false)
    }
  }
  
  func didFail(with error: ErrorWithBoolModel) {
    self.error.send(error)
    let event = TLEvent(flow: .checkout, action: .error)
    let model = TLErrorCallback(event: event,
                                error: L.errorPaymentTitle,
                                message: error.error.localizedDescription)
    onError?(model)
  }
  
  func setContent() {
    guard
      let invoiceInfo = invoiceInfo,
      let balance = balance,
      let isVirtual = isVirtual,
      let walletBalance = balance.balances[invoiceInfo.currency]?.spendable else { return }
    content.send((invoiceInfo, walletBalance, balance.paymentMethods, isVirtual))
  }
  
}
