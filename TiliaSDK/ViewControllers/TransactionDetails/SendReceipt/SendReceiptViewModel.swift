//
//  SendReceiptViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import Foundation
import Combine

protocol SendReceiptViewModelInputProtocol {
  func checkEmail(_ email: String)
  func sendEmail(_ email: String)
}

protocol SendReceiptViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
  var dismiss: PassthroughSubject<Void, Never> { get }
  var isEmailValid: PassthroughSubject<Bool, Never> { get }
}

protocol SendReceiptViewModelProtocol: SendReceiptViewModelInputProtocol, SendReceiptViewModelOutputProtocol { }

final class SendReceiptViewModel: SendReceiptViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<Error, Never>()
  let dismiss = PassthroughSubject<Void, Never>()
  let isEmailValid = PassthroughSubject<Bool, Never>()
  
  private let transactionId: String
  private let manager: NetworkManager
  private let onError: ((TLErrorCallback) -> Void)?
  private let onUpdate: ((TLUpdateCallback) -> Void)?
  
  init(transactionId: String,
       manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    self.transactionId = transactionId
    self.manager = manager
    self.onUpdate = onUpdate
    self.onError = onError
  }
  
  func checkEmail(_ email: String) {
    isEmailValid.send(SendReceiptValidator.isEmailValid(email))
  }
  
  func sendEmail(_ email: String) {
    loading.send(true)
    manager.sendTransactionReceipt(withId: transactionId, email: email) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success:
        self.dismiss.send()
        let event = TLEvent(flow: .transactionDetails, action: .receiptSent)
        let model = TLUpdateCallback(event: event, message: L.receiptSent)
        self.onUpdate?(model)
      case .failure(let error):
        self.loading.send(false)
        self.error.send(error)
        let event = TLEvent(flow: .transactionDetails, action: .error)
        let model = TLErrorCallback(event: event,
                                    error: L.errorSendReceiptTitle,
                                    message: error.localizedDescription)
        self.onError?(model)
      }
    }
  }
  
}
