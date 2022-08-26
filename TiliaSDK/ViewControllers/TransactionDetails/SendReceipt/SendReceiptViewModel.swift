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
  
  func checkEmail(_ email: String) {
    isEmailValid.send(SendReceiptValidator.isEmailValid(email))
  }
  
  func sendEmail(_ email: String) {
    loading.send(true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      self.loading.send(false)
      self.dismiss.send()
    }
  }
  
}
