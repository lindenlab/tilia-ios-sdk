//
//  TransactionHistoryViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.09.2022.
//

import Combine

protocol TransactionHistoryViewModelInputProtocol {
  func checkIsTosRequired()
  func selectAccount(with name: String)
  func complete(isFromCloseAction: Bool)
}

protocol TransactionHistoryViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<ErrorWithBoolModel, Never> { get }
  var needToAcceptTos: PassthroughSubject<Void, Never> { get }
  var dismiss: PassthroughSubject<Void, Never> { get }
  var content: PassthroughSubject<UserDetailInfoModel, Never> { get }
  var selectTransaction: PassthroughSubject<Void, Never> { get }
  var setAccountId: PassthroughSubject<String?, Never> { get }
}

protocol TransactionHistoryDataStore {
  var selectedTransaction: TransactionDetailsModel? { get }
  var manager: NetworkManager { get }
  var onUpdate: ((TLUpdateCallback) -> Void)? { get }
  var onTosComplete: (TLCompleteCallback) -> Void { get }
  var onComplete: ((TLCompleteCallback) -> Void)? { get }
  var onError: ((TLErrorCallback) -> Void)? { get }
}

protocol TransactionHistoryViewModelProtocol: TransactionHistoryViewModelInputProtocol, TransactionHistoryViewModelOutputProtocol { }

final class TransactionHistoryViewModel: TransactionHistoryViewModelProtocol, TransactionHistoryDataStore {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<ErrorWithBoolModel, Never>()
  let needToAcceptTos = PassthroughSubject<Void, Never>()
  let dismiss = PassthroughSubject<Void, Never>()
  let content = PassthroughSubject<UserDetailInfoModel, Never>()
  let selectTransaction = PassthroughSubject<Void, Never>()
  let setAccountId = PassthroughSubject<String?, Never>()
  
  private(set) var selectedTransaction: TransactionDetailsModel?
  let manager: NetworkManager
  let onUpdate: ((TLUpdateCallback) -> Void)?
  private(set) lazy var onTosComplete: (TLCompleteCallback) -> Void = { [weak self] in
    guard let self = self else { return }
    if $0.state == .completed {
      self.loadUserInfo()
    } else {
      self.dismiss.send()
    }
    self.onComplete?($0)
  }
  let onComplete: ((TLCompleteCallback) -> Void)?
  let onError: ((TLErrorCallback) -> Void)?
  
  private var isLoaded = false
  private var userInfo: UserDetailInfoModel?
  private var selectedAccountName: String?
  
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
          self.loadUserInfo()
        }
      case .failure(let error):
        self.loading.send(false)
        self.didFail(with: .init(error: error, value: true))
      }
    }
  }
  
  func selectAccount(with name: String) {
    guard selectedAccountName != name, let userInfo = userInfo else { return }
    selectedAccountName = name
    if userInfo.defaultAccountName == name {
      setAccountId.send(nil)
    } else if let account = userInfo.mergedAccounts.first(where: { $0.resourceId == name }) {
      setAccountId.send(account.resourceId)
    }
  }
  
  func complete(isFromCloseAction: Bool) {
    let event = TLEvent(flow: .transactionHistory,
                        action: isFromCloseAction ? .closedByUser : isLoaded ? .completed : .cancelledByUser)
    let model = TLCompleteCallback(event: event,
                                   state: isFromCloseAction ? .error : isLoaded ? .completed : .cancelled)
    onComplete?(model)
  }
  
}

// MARK: - TransactionHistoryChildViewModelDelegate

extension TransactionHistoryViewModel: TransactionHistoryChildViewModelDelegate {
  
  func transactionHistoryChildViewModelDidLoad() {
    guard !isLoaded else { return }
    isLoaded = true
  }
  
  func transactionHistoryChildViewModel(didFailWithError error: Error) {
    didFail(with: .init(error: error, value: false))
  }
  
  func transactionHistoryChildViewModel(didSelectTransaction transaction: TransactionDetailsModel) {
    selectedTransaction = transaction
    selectTransaction.send()
    selectedTransaction = nil
  }
  
}

// MARK: - Private Methods

private extension TransactionHistoryViewModel {
  
  func loadUserInfo() {
    manager.getUserInfo { [weak self] result in
      guard let self = self else { return }
      self.loading.send(false)
      switch result {
      case .success(let model):
        self.userInfo = model
        self.selectedAccountName = model.defaultAccountName
        self.content.send(model)
      case .failure(let error):
        self.didFail(with: .init(error: error, value: true))
      }
    }
  }
  
  func didFail(with error: ErrorWithBoolModel) {
    self.error.send(error)
    let event = TLEvent(flow: .transactionHistory, action: .error)
    let model = TLErrorCallback(event: event,
                                error: L.errorTransactionHistoryTitle,
                                message: error.error.localizedDescription)
    onError?(model)
  }
  
}
