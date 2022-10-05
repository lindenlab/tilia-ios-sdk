//
//  TransactionHistoryChildViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 04.10.2022.
//

import Combine

typealias TransactionHistoryChildContent = (models: [TransactionDetailsModel], lastItem: TransactionDetailsModel?, needReload: Bool, hasMore: Bool)

protocol TransactionHistoryChildViewModelDelegate: AnyObject {
  func transactionHistoryChildViewModelDidLoad()
  func transactionHistoryChildViewModel(didFailWithError error: Error)
  func transactionHistoryChildViewModel(didSelectTransaction transaction: TransactionDetailsModel)
}

protocol TransactionHistoryChildViewModelInputProtocol {
  func loadTransactions()
  func loadMoreTransactions()
  func selectTransaction(at index: Int)
}

protocol TransactionHistoryChildViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var content: PassthroughSubject<TransactionHistoryChildContent, Never> { get }
}

protocol TransactionHistoryChildViewModelProtocol: TransactionHistoryChildViewModelInputProtocol, TransactionHistoryChildViewModelOutputProtocol { }

final class TransactionHistoryChildViewModel: TransactionHistoryChildViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let content = PassthroughSubject<TransactionHistoryChildContent, Never>()
  
  private let manager: NetworkManager
  private weak var delegate: TransactionHistoryChildViewModelDelegate?
  private var transactions: [TransactionDetailsModel] = []
  private var offset = 0
  private var isLoadingMore = false
  
  init(manager: NetworkManager, delegate: TransactionHistoryChildViewModelDelegate?) {
    self.manager = manager
    self.delegate = delegate
  }
  
  func loadTransactions() {
    loading.send(true)
    offset = 0
    manager.getTransactionHistory(withLimit: 20, offset: offset) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        self.transactions = model.transactions
        let hasMore = self.hasMore(total: model.total)
        self.content.send((model.transactions, nil, true, hasMore))
        self.delegate?.transactionHistoryChildViewModelDidLoad()
      case .failure(let error):
        self.delegate?.transactionHistoryChildViewModel(didFailWithError: error)
      }
      self.loading.send(false)
    }
  }
  
  func loadMoreTransactions() {
    guard !isLoadingMore else { return }
    isLoadingMore = true
    offset += 1
    manager.getTransactionHistory(withLimit: 20, offset: offset) { [weak self] result in
      guard let self = self, self.offset != 0 else { return }
      switch result {
      case .success(let model):
        let lastItem = self.transactions.last
        self.transactions.append(contentsOf: model.transactions)
        let hasMore = self.hasMore(total: model.total)
        self.content.send((model.transactions, lastItem, false, hasMore))
      case .failure(let error):
        self.offset -= 1
        self.delegate?.transactionHistoryChildViewModel(didFailWithError: error)
      }
      self.isLoadingMore = false
    }
  }
  
  func selectTransaction(at index: Int) {
    delegate?.transactionHistoryChildViewModel(didSelectTransaction: transactions[index])
  }
  
}

// MARK: - Private Methods

private extension TransactionHistoryChildViewModel {
  
  func hasMore(total: Int) -> Bool {
    return transactions.count < total
  }
  
}
