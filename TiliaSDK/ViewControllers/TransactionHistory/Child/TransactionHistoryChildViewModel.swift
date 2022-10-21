//
//  TransactionHistoryChildViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 04.10.2022.
//

import Combine

typealias TransactionHistoryChildContent = (models: [TransactionDetailsModel], lastItem: TransactionDetailsModel?, needReload: Bool)

protocol TransactionHistoryChildViewModelDelegate: AnyObject {
  func transactionHistoryChildViewModelDidLoad()
  func transactionHistoryChildViewModel(didFailWithError error: Error)
  func transactionHistoryChildViewModel(didSelectTransaction transaction: TransactionDetailsModel)
}

protocol TransactionHistoryChildViewModelInputProtocol {
  func loadTransactions()
  func loadMoreTransactionsIfNeeded()
  func selectTransaction(at index: Int)
}

protocol TransactionHistoryChildViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var loadingMore: CurrentValueSubject<Bool, Never> { get }
  var content: PassthroughSubject<TransactionHistoryChildContent, Never> { get }
}

protocol TransactionHistoryChildViewModelProtocol: TransactionHistoryChildViewModelInputProtocol, TransactionHistoryChildViewModelOutputProtocol { }

final class TransactionHistoryChildViewModel: TransactionHistoryChildViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let loadingMore = CurrentValueSubject<Bool, Never>(false)
  let content = PassthroughSubject<TransactionHistoryChildContent, Never>()
  
  private let manager: NetworkManager
  private let sectionType: TransactionHistorySectionTypeModel
  private weak var delegate: TransactionHistoryChildViewModelDelegate?
  private var transactions: [TransactionDetailsModel] = []
  private var offset = 0
  private var hasMore = false
  
  init(manager: NetworkManager,
       sectionType: TransactionHistorySectionTypeModel,
       delegate: TransactionHistoryChildViewModelDelegate?) {
    self.manager = manager
    self.sectionType = sectionType
    self.delegate = delegate
  }
  
  func loadTransactions() {
    loading.send(true)
    offset = 0
    hasMore = false
    if loadingMore.value {
      loadingMore.send(false)
    }
    manager.getTransactionHistory(withLimit: limit, offset: offset, sectionType: sectionType) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        self.transactions = model.transactions
        self.hasMore = self.hasMore(total: model.total)
        if self.hasMore {
          self.transactions.reserveCapacity(model.total)
        }
        self.content.send((model.transactions, nil, true))
        self.delegate?.transactionHistoryChildViewModelDidLoad()
      case .failure(let error):
        self.delegate?.transactionHistoryChildViewModel(didFailWithError: error)
      }
      self.loading.send(false)
    }
  }
  
  func loadMoreTransactionsIfNeeded() {
    guard hasMore && !loadingMore.value else { return }
    loadingMore.send(true)
    manager.getTransactionHistory(withLimit: limit, offset: offset, sectionType: sectionType) { [weak self] result in
      guard let self = self, self.hasMore else { return }
      switch result {
      case .success(let model):
        let lastItem = self.transactions.last
        self.transactions.append(contentsOf: model.transactions)
        self.hasMore = self.hasMore(total: model.total)
        self.content.send((model.transactions, lastItem, false))
      case .failure(let error):
        self.delegate?.transactionHistoryChildViewModel(didFailWithError: error)
      }
      self.loadingMore.send(false)
    }
  }
  
  func selectTransaction(at index: Int) {
    delegate?.transactionHistoryChildViewModel(didSelectTransaction: transactions[index])
  }
  
}

// MARK: - Private Methods

private extension TransactionHistoryChildViewModel {
  
  var limit: Int { return 20 }
  
  func hasMore(total: Int) -> Bool {
    offset += limit
    return total > offset
  }
  
}
