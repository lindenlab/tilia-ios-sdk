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
    case .update: return L.updateYourEmail
    }
  }
  
  var successTitle: String {
    switch self {
    case .verify: return L.yourEmailIsVerified
    case .update: return L.yourEmailIsUpdated
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
  var validator: VerifyEmailValidator { get }
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<ErrorWithBoolModel, Never> { get }
  var emailVerified: PassthroughSubject<Void, Never> { get }
}

protocol VerifyEmailViewModelProtocol: VerifyEmailViewModelInputProtocol, VerifyEmailViewModelOutputProtocol { }

final class VerifyEmailViewModel: VerifyEmailViewModelProtocol {
  
  let validator = VerifyEmailValidator()
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<ErrorWithBoolModel, Never>()
  let emailVerified = PassthroughSubject<Void, Never>()
  
  let mode: VerifyEmailMode
  let email: String
  
  private let flow: TLEvent.Flow
  private let manager: NetworkManager
  private let onEmailVerified: (VerifyEmailMode) -> Void
  private let onUpdate: ((TLUpdateCallback) -> Void)?
  private let onError: ((TLErrorCallback) -> Void)?
  private var nonce: String?
  
  init(email: String,
       flow: TLEvent.Flow,
       mode: VerifyEmailMode,
       manager: NetworkManager,
       onEmailVerified: @escaping (VerifyEmailMode) -> Void,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    self.email = email
    self.flow = flow
    self.mode = mode
    self.manager = manager
    self.onEmailVerified = onEmailVerified
    self.onUpdate = onUpdate
    self.onError = onError
  }
  
  func sendCode() {
    loading.send(true)
    manager.beginVerifyUserEmail(email) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        self.nonce = model.nonce
        self.loading.send(false)
      case .failure(let error):
        self.loading.send(false)
        self.didFail(with: .init(error: error, value: true))
      }
    }
  }
  
  func verifyCode(_ code: String) {
    guard validator.isCodeValid(code), let nonce = nonce else { return }
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
    let event = TLEvent(flow: flow, action: .emailVerified)
    let model = TLUpdateCallback(event: event, message: mode.successTitle)
    onUpdate?(model)
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
