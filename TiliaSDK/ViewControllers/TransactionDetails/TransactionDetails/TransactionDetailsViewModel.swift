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
  var onSendReceiptUpdate: ((TLUpdateCallback) -> Void)? { get }
  var onSendReceiptError: ((TLErrorCallback) -> Void)? { get }
}

protocol TransactionDetailsViewModelProtocol: TransactionDetailsViewModelInputProtocol, TransactionDetailsViewModelOutputProtocol {
  
}

final class TransactionDetailsViewModel: TransactionDetailsViewModelProtocol, TransactionDetailsDataStore {
  
  let manager: NetworkManager
  var onSendReceiptUpdate: ((TLUpdateCallback) -> Void)? {
    return onUpdate
  }
  var onSendReceiptError: ((TLErrorCallback) -> Void)? {
    return onError
  }
  
  private let onComplete: ((TLCompleteCallback) -> Void)?
  private let onError: ((TLErrorCallback) -> Void)?
  private let onUpdate: ((TLUpdateCallback) -> Void)?
  
  init(manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    self.manager = manager
    self.onUpdate = onUpdate
    self.onComplete = onComplete
    self.onError = onError
  }
  
}
