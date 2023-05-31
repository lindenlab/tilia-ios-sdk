//
//  CheckoutViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import Foundation
import Combine

typealias CheckoutContent = (invoiceInfo: InvoiceInfoModel, walletBalance: BalanceModel, paymentMethods: [PaymentMethodModel], isVirtual: Bool)
typealias CheckoutPaymentIsEnabledBySectionIndex = (sectionIndex: Int, isEnabled: Bool)

protocol CheckoutViewModelInputProtocol {
  func checkIsTosRequired()
  func payInvoice()
  func complete(isFromCloseAction: Bool)
  func selectPaymentMethod(at indexPath: IndexPath, isSelected: Bool)
  func selectPaymentMethod(at indexPath: IndexPath)
  func removePaymentMethod(at index: Int)
  func renamePaymentMethod(at index: Int, with text: String)
}

protocol CheckoutViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<ErrorWithBoolModel, Never> { get }
  var needToAcceptTos: PassthroughSubject<Void, Never> { get }
  var content: PassthroughSubject<CheckoutContent, Never> { get }
  var successfulPayment: CurrentValueSubject<Bool, Never> { get }
  var dismiss: PassthroughSubject<Void, Never> { get }
  var createInvoiceLoading: CurrentValueSubject<Bool, Never> { get }
  var payButtonIsEnabled: PassthroughSubject<CheckoutPaymentIsEnabledBySectionIndex, Never> { get }
  var deselectIndex: PassthroughSubject<IndexPath, Never> { get }
  var selectIndex: PassthroughSubject<IndexPath, Never> { get }
  var updateSummary: PassthroughSubject<InvoiceInfoModel, Never> { get }
  var updatePayment: PassthroughSubject<CheckoutContent, Never> { get }
  var paymentMethodsAreEnabled: PassthroughSubject<CheckoutPaymentIsEnabledBySectionIndex, Never> { get }
}

protocol CheckoutDataStore {
  var manager: NetworkManager { get }
  var onTosComplete: (TLCompleteCallback) -> Void { get }
  var onReload: () -> Void { get }
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
  let payButtonIsEnabled = PassthroughSubject<CheckoutPaymentIsEnabledBySectionIndex, Never>()
  let deselectIndex = PassthroughSubject<IndexPath, Never>()
  let selectIndex = PassthroughSubject<IndexPath, Never>()
  let updateSummary = PassthroughSubject<InvoiceInfoModel, Never>()
  let updatePayment = PassthroughSubject<CheckoutContent, Never>()
  let paymentMethodsAreEnabled = PassthroughSubject<CheckoutPaymentIsEnabledBySectionIndex, Never>()
  
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
  private(set) lazy var onReload: () -> Void = { [weak self] in
    self?.getUserBalance()
  }
  let onError: ((TLErrorCallback) -> Void)?
  
  private let onComplete: ((TLCompleteCallback) -> Void)?
  private let onUpdate: ((TLUpdateCallback) -> Void)?
  private let authorizedInvoiceId: String
  private var invoiceId: String?
  private var walletBalance: BalanceModel?
  private var paymentMethods: [PaymentMethodModel] = []
  private var invoiceInfo: InvoiceInfoModel?
  private var isEscrow: Bool?
  private var isVirtual: Bool?
  private var selectedWalletIndex: IndexPath? {
    didSet {
      oldValue.map { deselectIndex.send($0) }
      selectedWalletIndex.map { selectIndex.send($0) }
    }
  }
  private var selectedPaymentMethodIndex: IndexPath? {
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
        self.loading.send(false)
        self.didFail(with: .init(error: error, value: true))
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
      self.loading.send(false)
      switch result {
      case .success:
        self.successfulPayment.send(true)
        self.onUpdate?(TLUpdateCallback(event: TLEvent(flow: .checkout, action: .paymentProcessed),
                                        message: L.paymentProcessed))
      case .failure(let error):
        self.didFail(with: .init(error: error, value: false))
      }
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
  
  func selectPaymentMethod(at indexPath: IndexPath, isSelected: Bool) {
    selectedWalletIndex = isSelected ? indexPath : nil
    selectedPaymentMethodIndex = nil
    guard
      let walletBalance = walletBalance,
      let invoiceInfo = invoiceInfo else { return }
    if walletBalance.balance >= invoiceInfo.amount && isSelected {
      paymentMethodsAreEnabled.send((indexPath.section, false))
      createNonVirtualInvoice(with: indexPath.section)
    } else {
      paymentMethodsAreEnabled.send((indexPath.section, true))
      payButtonIsEnabled.send((indexPath.section, false))
    }
  }
  
  func selectPaymentMethod(at indexPath: IndexPath) {
    guard selectedPaymentMethodIndex != indexPath else { return }
    selectedPaymentMethodIndex = indexPath
    createNonVirtualInvoice(with: indexPath.section)
  }
  
  func removePaymentMethod(at index: Int) {
    loading.send(true)
    manager.deletePaymentMethod(with: paymentMethods[index].id) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success:
        self.getUserBalance()
        let event = TLEvent(flow: .checkout, action: .paymentMethodDeleted)
        let model = TLUpdateCallback(event: event, message: L.paymentMethodDeleted)
        self.onUpdate?(model)
      case .failure(let error):
        self.loading.send(false)
        self.didFail(with: .init(error: error, value: false))
      }
    }
  }
  
  func renamePaymentMethod(at index: Int, with text: String) {
    guard paymentMethods[index].display != text else { return }
    loading.send(true)
    manager.renamePaymentMethod(withNewName: text, byId: paymentMethods[index].id) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success:
        self.getUserBalance()
        let event = TLEvent(flow: .checkout, action: .paymentMethodRenamed)
        let model = TLUpdateCallback(event: event, message: L.paymentMethodRenamed)
        self.onUpdate?(model)
      case .failure(let error):
        self.loading.send(false)
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
        self.loading.send(false)
        self.didFail(with: .init(error: error, value: true))
      }
    }
    
  }
  
  func createVirtualInvoice() {
    guard let isEscrow = isEscrow else { return }
    manager.createInvoice(withId: authorizedInvoiceId, isEscrow: isEscrow, paymentMethods: []) { [weak self] result in
      guard let self = self else { return }
      self.loading.send(false)
      switch result {
      case .success(let model):
        self.invoiceId = model.invoiceId
        self.invoiceInfo = model.info
        self.setContent()
      case .failure(let error):
        self.didFail(with: .init(error: error, value: true))
      }
    }
  }
  
  func createNonVirtualInvoice(with paymentSectionIndex: Int) {
    guard let isEscrow = isEscrow else { return }
    createInvoiceLoading.send(true)
    payButtonIsEnabled.send((paymentSectionIndex, false))
    var paymentMethods: [PaymentMethodModel] = []
    if let index = selectedWalletIndex, let walletBalance = walletBalance {
      var model = self.paymentMethods[index.row]
      model.amount = selectedPaymentMethodIndex == nil ? nil : walletBalance.balance
      paymentMethods.append(model)
    }
    if let index = selectedPaymentMethodIndex {
      var model = self.paymentMethods[index.row]
      model.amount = selectedWalletIndex == nil ? nil : 0
      paymentMethods.append(model)
    }
    manager.createInvoice(withId: authorizedInvoiceId, isEscrow: isEscrow, paymentMethods: paymentMethods) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        self.invoiceId = model.invoiceId
        self.invoiceInfo = model.info
        self.payButtonIsEnabled.send((paymentSectionIndex, true))
        self.updateSummary.send(model.info)
      case .failure(let error):
        self.selectedWalletIndex = nil
        self.selectedPaymentMethodIndex = nil
        self.invoiceId = nil
        self.didFail(with: .init(error: error, value: false))
      }
      self.createInvoiceLoading.send(false)
    }
  }
  
  func getUserBalance() {
    selectedWalletIndex = nil
    selectedPaymentMethodIndex = nil
    loading.send(true)
    manager.getUserBalance { [weak self] result in
      guard let self = self else { return }
      self.loading.send(false)
      switch result {
      case .success(let model):
        self.paymentMethods = model.paymentMethods
        self.updatePaymentObserver()
      case .failure(let error):
        self.didFail(with: .init(error: error, value: true))
      }
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
  
  func updatePaymentObserver() {
    guard
      let invoiceInfo = invoiceInfo,
      let isVirtual = isVirtual,
      let walletBalance = walletBalance else { return }
    updatePayment.send((invoiceInfo, walletBalance, paymentMethods, isVirtual))
  }
  
}
