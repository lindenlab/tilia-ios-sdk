//
//  PaymentSelectionViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.05.2023.
//

import Foundation
import Combine

typealias PaymentSelectionContent = (walletBalance: BalanceModel?, amount: Double?, paymentMethods: [PaymentMethodModel])
typealias PaymentSelectionIsEnabledBySectionIndex = (sectionIndex: Int, isEnabled: Bool)

protocol PaymentSelectionViewModelInputProtocol {
  func checkIsTosRequired()
  func selectPaymentMethod(at indexPath: IndexPath, isSelected: Bool)
  func selectPaymentMethod(at indexPath: IndexPath)
  func removePaymentMethod(at index: Int)
  func renamePaymentMethod(at index: Int, with text: String)
  func useSelectedPaymentMethod()
  func complete(isFromCloseAction: Bool)
}

protocol PaymentSelectionViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<ErrorWithBoolModel, Never> { get }
  var needToAcceptTos: PassthroughSubject<Void, Never> { get }
  var content: PassthroughSubject<PaymentSelectionContent, Never> { get }
  var dismiss: PassthroughSubject<Void, Never> { get }
  var paymentButtonIsEnabled: PassthroughSubject<PaymentSelectionIsEnabledBySectionIndex, Never> { get }
  var deselectIndex: PassthroughSubject<IndexPath, Never> { get }
  var selectIndex: PassthroughSubject<IndexPath, Never> { get }
  var paymentMethodsAreEnabled: PassthroughSubject<PaymentSelectionIsEnabledBySectionIndex, Never> { get }
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
  let content = PassthroughSubject<PaymentSelectionContent, Never>()
  let dismiss = PassthroughSubject<Void, Never>()
  let paymentButtonIsEnabled = PassthroughSubject<PaymentSelectionIsEnabledBySectionIndex, Never>()
  let deselectIndex = PassthroughSubject<IndexPath, Never>()
  let selectIndex = PassthroughSubject<IndexPath, Never>()
  let paymentMethodsAreEnabled = PassthroughSubject<PaymentSelectionIsEnabledBySectionIndex, Never>()
  
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
  
  private let amount: Double?
  private let currencyCode: String?
  private let onUpdate: ((TLUpdateCallback) -> Void)?
  private let onComplete: ((TLCompleteCallback) -> Void)?
  private var walletBalance: BalanceModel?
  private var paymentMethods: [PaymentMethodModel] = []
  private var isPaymentMethodsUpdated = false
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
  
  init(manager: NetworkManager,
       amount: Double?,
       currencyCode: String?,
       onUpdate: ((TLUpdateCallback) -> Void)? = nil,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    self.manager = manager
    self.amount = amount?.toNilIfEmpty()
    self.currencyCode = currencyCode?.toNilIfEmpty()
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
  
  func selectPaymentMethod(at indexPath: IndexPath, isSelected: Bool) {
    selectedWalletIndex = isSelected ? indexPath : nil
    selectedPaymentMethodIndex = nil
    guard
      let walletBalance = walletBalance,
      let amount = amount else { return }
    if walletBalance.balance >= amount && isSelected {
      paymentMethodsAreEnabled.send((indexPath.section, false))
      paymentButtonIsEnabled.send((indexPath.section, true))
    } else {
      paymentMethodsAreEnabled.send((indexPath.section, true))
      paymentButtonIsEnabled.send((indexPath.section, false))
    }
  }
  
  func selectPaymentMethod(at indexPath: IndexPath) {
    guard selectedPaymentMethodIndex != indexPath else { return }
    selectedPaymentMethodIndex = indexPath
    paymentButtonIsEnabled.send((indexPath.section, true))
  }
  
  func removePaymentMethod(at index: Int) {
    // Here will be a request
    let event = TLEvent(flow: .paymentSelection, action: .paymentMethodDeleted)
    let model = TLUpdateCallback(event: event, message: L.paymentMethodDeleted)
    onUpdate?(model)
  }
  
  func renamePaymentMethod(at index: Int, with text: String) {
    guard !text.isEmpty else { return }
    // Here will be a request
    let event = TLEvent(flow: .paymentSelection, action: .paymentMethodRenamed)
    let model = TLUpdateCallback(event: event, message: L.paymentMethodRenamed)
    onUpdate?(model)
  }
  
  func useSelectedPaymentMethod() {
    isPaymentMethodsUpdated = true
    dismiss.send()
  }
  
  func complete(isFromCloseAction: Bool) {
    var paymentMethods: [PaymentMethodModel] = []
    if let index = selectedWalletIndex {
      var model = self.paymentMethods[index.row]
      model.amount = walletBalance?.balance
      paymentMethods.append(model)
    }
    if let index = selectedPaymentMethodIndex {
      var model = self.paymentMethods[index.row]
      model.amount = model.type.isWallet ? walletBalance?.balance : 0
      paymentMethods.append(model)
    }
    let data = TLPaymentMethods(paymentMethods: paymentMethods.map { .init(id: $0.id, amount: $0.amount ?? 0) })
    let event = TLEvent(flow: .paymentSelection,
                        action: isFromCloseAction ? .closedByUser : isPaymentMethodsUpdated ? .completed : .cancelledByUser)
    let model = TLCompleteCallback(event: event,
                                   state: isFromCloseAction ? .error : isPaymentMethodsUpdated ? .completed : .cancelled,
                                   data: isPaymentMethodsUpdated ? data : nil)
    onComplete?(model)
  }
  
}

// MARK: - Private Methods

private extension PaymentSelectionViewModel {
  
  func getPaymentMethods() {
    selectedWalletIndex = nil
    selectedPaymentMethodIndex = nil
    loading.send(true)
    manager.getUserBalance { [weak self] result in
      guard let self = self else { return }
      self.loading.send(false)
      switch result {
      case .success(let model):
        self.paymentMethods = model.paymentMethods.filter {
          if $0.type.isWallet {
            if let balance = model.balances[self.currencyCode ?? "USD"] {
              self.walletBalance = balance.spendable
              return true
            } else {
              return false
            }
          } else {
            return true
          }
        }
        self.content.send((self.walletBalance, self.amount, self.paymentMethods))
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
