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
  func selectPaymentMethod(at index: Int, isSelected: Bool)
  func selectPaymentMethod(at index: Int)
}

protocol CheckoutViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<ErrorWithBoolModel, Never> { get }
  var needToAcceptTos: PassthroughSubject<Void, Never> { get }
  var content: PassthroughSubject<CheckoutContent, Never> { get }
  var successfulPayment: CurrentValueSubject<Bool, Never> { get }
  var dismiss: PassthroughSubject<Void, Never> { get }
  var createInvoiceLoading: CurrentValueSubject<Bool, Never> { get }
  var payButtonIsEnabled: PassthroughSubject<Bool, Never> { get }
  var deselectIndex: PassthroughSubject<Int, Never> { get }
  var selectIndex: PassthroughSubject<Int, Never> { get }
  var updateSummary: PassthroughSubject<InvoiceInfoModel, Never> { get }
  var paymentMethodsAreEnabled: PassthroughSubject<Bool, Never> { get }
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
  let createInvoiceLoading = CurrentValueSubject<Bool, Never>(false)
  let payButtonIsEnabled = PassthroughSubject<Bool, Never>()
  let deselectIndex = PassthroughSubject<Int, Never>()
  let selectIndex = PassthroughSubject<Int, Never>()
  let updateSummary = PassthroughSubject<InvoiceInfoModel, Never>()
  let paymentMethodsAreEnabled = PassthroughSubject<Bool, Never>()
  
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
  private var walletBalance: BalanceModel?
  private var paymentMethods: [CheckoutPaymentMethodModel] = []
  private var invoiceInfo: InvoiceInfoModel?
  private var isEscrow: Bool?
  private var isVirtual: Bool?
  private var selectedWalletIndex: Int? {
    didSet {
      oldValue.map { deselectIndex.send($0) }
      selectedWalletIndex.map { selectIndex.send($0) }
    }
  }
  private var selectedPaymentMethodIndex: Int? {
    didSet {
      oldValue.map { deselectIndex.send($0) }
      selectedPaymentMethodIndex.map { selectIndex.send($0) }
    }
  }
  
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
  
  func selectPaymentMethod(at index: Int, isSelected: Bool) {
    selectedWalletIndex = isSelected ? index : nil
    selectedPaymentMethodIndex = nil
    guard
      let walletBalance = walletBalance,
      let invoiceInfo = invoiceInfo else { return }
    if walletBalance.balance >= invoiceInfo.amount && isSelected {
      paymentMethodsAreEnabled.send(false)
      createNonVirtualInvoice()
    } else {
      paymentMethodsAreEnabled.send(true)
      payButtonIsEnabled.send(false)
    }
  }
  
  func selectPaymentMethod(at index: Int) {
    guard selectedPaymentMethodIndex != index else { return }
    selectedPaymentMethodIndex = index
    createNonVirtualInvoice()
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
        self.walletBalance = balance.balances[invoiceDetails.info.currency]?.spendable
        self.paymentMethods = balance.paymentMethods
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
    manager.createInvoice(withId: authorizedInvoiceId, isEscrow: isEscrow, paymentMethods: []) { [weak self] result in
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
  
  func createNonVirtualInvoice() {
    guard let isEscrow = isEscrow else { return }
    createInvoiceLoading.send(true)
    payButtonIsEnabled.send(false)
    var paymentMethods: [CheckoutPaymentMethodModel] = []
    if let index = selectedWalletIndex, let walletBalance = walletBalance {
      var model = self.paymentMethods[index]
      model.amount = selectedPaymentMethodIndex == nil ? nil : walletBalance.balance
      paymentMethods.append(model)
    }
    if let index = selectedPaymentMethodIndex {
      var model = self.paymentMethods[index]
      model.amount = selectedWalletIndex == nil ? nil : 0
      paymentMethods.append(model)
    }
    manager.createInvoice(withId: authorizedInvoiceId, isEscrow: isEscrow, paymentMethods: paymentMethods) { [weak self] result in
      guard let self = self else { return }
      self.createInvoiceLoading.send(false)
      switch result {
      case .success(let model):
        self.invoiceId = model.invoiceId
        self.invoiceInfo = model.info
        self.payButtonIsEnabled.send(true)
        self.updateSummary.send(model.info)
      case .failure(let error):
        self.selectedWalletIndex = nil
        self.selectedPaymentMethodIndex = nil
        self.invoiceId = nil
        self.didFail(with: .init(error: error, value: false))
      }
    }
  }
  
  func getUserBalance() {
    selectedWalletIndex = nil
    selectedPaymentMethodIndex = nil
    loading.send(true)
    manager.getUserBalance { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        self.paymentMethods = model.paymentMethods
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
      let isVirtual = isVirtual,
      let walletBalance = walletBalance else { return }
    content.send((invoiceInfo, walletBalance, paymentMethods, isVirtual))
  }
  
}
