//
//  TransactionDetailsViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import Foundation

protocol TransactionDetailsViewModelInputProtocol {
  
}

protocol TransactionDetailsViewModelOutputProtocol {
  
}

protocol TransactionDetailsDataStore {
  var manager: NetworkManager { get }
  var onUpdate: ((TLUpdateCallback) -> Void)? { get }
  var onError: ((TLErrorCallback) -> Void)? { get }
}

protocol TransactionDetailsViewModelProtocol: TransactionDetailsViewModelInputProtocol, TransactionDetailsViewModelOutputProtocol {
  
}

final class TransactionDetailsViewModel: TransactionDetailsViewModelProtocol, TransactionDetailsDataStore {
  
  let manager: NetworkManager
  let onUpdate: ((TLUpdateCallback) -> Void)?
  let onError: ((TLErrorCallback) -> Void)?
  
  private let invoiceId: String
  private let onComplete: ((TLCompleteCallback) -> Void)?
  
  init(invoiceId: String,
       manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    self.invoiceId = invoiceId
    self.manager = manager
    self.onUpdate = onUpdate
    self.onComplete = onComplete
    self.onError = onError
  }
  
}
