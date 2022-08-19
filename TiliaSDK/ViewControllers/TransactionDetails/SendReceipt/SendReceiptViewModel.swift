//
//  SendReceiptViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import Foundation

protocol SendReceiptViewModelInputProtocol {
  
}

protocol SendReceiptViewModelOutputProtocol {
  
}

protocol SendReceiptViewModelProtocol: SendReceiptViewModelInputProtocol, SendReceiptViewModelOutputProtocol {
  
}

final class SendReceiptViewModel: SendReceiptViewModelProtocol {
  
  private let manager: NetworkManager
  private let onError: ((TLErrorCallback) -> Void)?
  private let onUpdate: ((TLUpdateCallback) -> Void)?
  
  init(manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    self.manager = manager
    self.onUpdate = onUpdate
    self.onError = onError
  }
  
}
