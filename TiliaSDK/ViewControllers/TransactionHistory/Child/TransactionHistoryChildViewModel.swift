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
  
  init(manager: NetworkManager, delegate: TransactionHistoryChildViewModelDelegate?) {
    self.manager = manager
    self.delegate = delegate
  }
  
  func loadTransactions() {
    loading.send(true)
    manager.getTransactionHistory(withLimit: 10, offset: 0) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        self.transactions = model.transactions
        self.content.send((model.transactions, nil, true, false))
        self.delegate?.transactionHistoryChildViewModelDidLoad()
      case .failure(let error):
        self.delegate?.transactionHistoryChildViewModel(didFailWithError: error)
      }
      self.loading.send(false)
    }
  }
  
  func loadMoreTransactions() {
    
  }
  
  func selectTransaction(at index: Int) {
    delegate?.transactionHistoryChildViewModel(didSelectTransaction: transactions[index])
  }
  
}
