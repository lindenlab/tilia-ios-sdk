//
//  PaymentSelectionViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.05.2023.
//

import Foundation
import Combine

typealias PaymentSelectionContent = (currencyCode: String, walletBalance: BalanceModel?, paymentMethods: [PaymentMethodModel])

protocol PaymentSelectionViewModelInputProtocol {
  func checkIsTosRequired()
  func selectPaymentMethod(at index: Int, isSelected: Bool)
  func selectPaymentMethod(at index: Int)
  func useSelectedPaymentMethod()
  func complete(isFromCloseAction: Bool)
}

protocol PaymentSelectionViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<ErrorWithBoolModel, Never> { get }
  var needToAcceptTos: PassthroughSubject<Void, Never> { get }
  var content: PassthroughSubject<PaymentSelectionContent, Never> { get }
  var dismiss: PassthroughSubject<Void, Never> { get }
  var paymentButtonIsEnabled: PassthroughSubject<Bool, Never> { get }
  var deselectIndex: PassthroughSubject<Int, Never> { get }
  var selectIndex: PassthroughSubject<Int, Never> { get }
  var paymentMethodsAreEnabled: PassthroughSubject<Bool, Never> { get }
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
  let paymentButtonIsEnabled = PassthroughSubject<Bool, Never>()
  let deselectIndex = PassthroughSubject<Int, Never>()
  let selectIndex = PassthroughSubject<Int, Never>()
  let paymentMethodsAreEnabled = PassthroughSubject<Bool, Never>()
  
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
  
  private let currencyCode: String
  private let onComplete: ((TLCompleteCallback) -> Void)?
  private let onUpdate: ((TLUpdateCallback) -> Void)?
  private var paymentMethods: [PaymentMethodModel] = []
  private var isPaymentMethodUpdated = false
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
  
  init(manager: NetworkManager,
       currencyCode: String,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    self.manager = manager
    self.currencyCode = currencyCode
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
  
  func selectPaymentMethod(at index: Int, isSelected: Bool) {
    selectedWalletIndex = isSelected ? index : nil
    selectedPaymentMethodIndex = nil
  }
  
  func selectPaymentMethod(at index: Int) {
    guard selectedPaymentMethodIndex != index else { return }
    selectedPaymentMethodIndex = index
  }
  
  func useSelectedPaymentMethod() {
    
  }
  
  func complete(isFromCloseAction: Bool) {
    let event = TLEvent(flow: .paymentSelection,
                        action: isFromCloseAction ? .closedByUser : isPaymentMethodUpdated ? .completed : .cancelledByUser)
    let model = TLCompleteCallback(event: event,
                                   state: isFromCloseAction ? .error : isPaymentMethodUpdated ? .completed : .cancelled)
    onComplete?(model)
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
        var walletBalance: BalanceModel?
        self.paymentMethods = model.paymentMethods.filter {
          if $0.type.isWallet {
            if let balance = model.balances[self.currencyCode] {
              walletBalance = balance.spendable
              return true
            } else {
              return false
            }
          } else {
            return true
          }
        }
        self.content.send((self.currencyCode, walletBalance, self.paymentMethods))
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
