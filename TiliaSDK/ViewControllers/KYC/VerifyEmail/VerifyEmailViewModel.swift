//
//  VerifyEmailViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.05.2023.
//

import Foundation
import Combine

enum VerifyEmailMode {
  
  case verify
  case update
  
  var title: String {
    switch self {
    case .verify: return L.verifyYourEmailTitle
    case .update: return L.updateYourEmailTitle
    }
  }
  
  var successTitle: String {
    switch self {
    case .verify: return L.yourEmailIsVerified
    case .update: return L.yourEmailIsUpdated
    }
  }
  
  func message(for email: String) -> String {
    switch self {
    case .verify: return L.verifyYourEmailMessage(with: email)
    case .update: return L.updateYourEmailMessage(with: email)
    }
  }
  
}

protocol VerifyEmailViewModelInputProtocol {
  func sendCode()
  func verifyCode(_ code: String)
  func complete()
}

protocol VerifyEmailViewModelOutputProtocol {
  var mode: VerifyEmailMode { get }
  var email: String { get }
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<ErrorWithBoolModel, Never> { get }
  var emailVerified: PassthroughSubject<Void, Never> { get }
}

protocol VerifyEmailViewModelProtocol: VerifyEmailViewModelInputProtocol, VerifyEmailViewModelOutputProtocol { }

final class VerifyEmailViewModel: VerifyEmailViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<ErrorWithBoolModel, Never>()
  let emailVerified = PassthroughSubject<Void, Never>()
  
  let mode: VerifyEmailMode
  let email: String
  
  private let flow: TLEvent.Flow
  private let manager: NetworkManager
  private let onEmailVerified: (VerifyEmailMode) -> Void
  private let onError: ((TLErrorCallback) -> Void)?
  private var nonce: String?
  
  init(email: String,
       flow: TLEvent.Flow,
       mode: VerifyEmailMode,
       manager: NetworkManager,
       onEmailVerified: @escaping (VerifyEmailMode) -> Void,
       onError: ((TLErrorCallback) -> Void)?) {
    self.email = email
    self.flow = flow
    self.mode = mode
    self.manager = manager
    self.onEmailVerified = onEmailVerified
    self.onError = onError
  }
  
  func sendCode() {
    loading.send(true)
    manager.beginVerifyUserEmail(email) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        self.nonce = model.nonce
      case .failure(let error):
        self.didFail(with: .init(error: error, value: true))
      }
      self.loading.send(false)
    }
  }
  
  func verifyCode(_ code: String) {
    guard let nonce = nonce else { return }
    loading.send(true)
    manager.finishVerifyUserEmail(with: .init(code: code, nonce: nonce)) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success:
        self.emailVerified.send()
      case .failure(let error):
        self.loading.send(false)
        self.didFail(with: .init(error: error, value: false))
      }
    }
  }
  
  func complete() {
    onEmailVerified(mode)
  }
  
}

// MARK: - Private Methods

private extension VerifyEmailViewModel {
  
  func didFail(with error: ErrorWithBoolModel) {
    self.error.send(error)
    let event = TLEvent(flow: flow, action: .error)
    let model = TLErrorCallback(event: event,
                                error: L.errorVerifyEmailTitle,
                                message: error.error.localizedDescription)
    self.onError?(model)
  }
  
}
