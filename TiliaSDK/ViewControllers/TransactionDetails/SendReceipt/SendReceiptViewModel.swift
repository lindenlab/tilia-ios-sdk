//
//  SendReceiptViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import Foundation
import Combine

enum SendReceiptMode {
  
  case verified
  case notVerified
  case edit
  
}

protocol SendReceiptViewModelInputProtocol {
  func load()
  func checkEmail(_ email: String)
  func sendEmail(_ email: String)
  func editEmail()
  func cancelEditEmail(_ email: String)
  func complete()
}

protocol SendReceiptViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var defaultEmail: PassthroughSubject<String, Never> { get }
  var sending: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<ErrorWithBoolModel, Never> { get }
  var emailSent: PassthroughSubject<Void, Never> { get }
  var isEmailValid: PassthroughSubject<Bool, Never> { get }
  var emailVerificationMode: PassthroughSubject<SendReceiptMode, Never> { get }
  var verifyEmail: PassthroughSubject<Void, Never> { get }
  var emailVerified: PassthroughSubject<String, Never> { get }
}

protocol SendReceiptDataStore {
  var manager: NetworkManager { get }
  var userEmail: String { get }
  var verifyEmailMode: VerifyEmailMode { get }
  var onEmailVerified: (VerifyEmailMode) -> Void { get }
  var onUpdate: ((TLUpdateCallback) -> Void)? { get }
  var onError: ((TLErrorCallback) -> Void)? { get }
}

protocol SendReceiptViewModelProtocol: SendReceiptViewModelInputProtocol, SendReceiptViewModelOutputProtocol { }

final class SendReceiptViewModel: SendReceiptViewModelProtocol, SendReceiptDataStore {
  
  let loading = PassthroughSubject<Bool, Never>()
  let defaultEmail = PassthroughSubject<String, Never>()
  let sending = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<ErrorWithBoolModel, Never>()
  let emailSent = PassthroughSubject<Void, Never>()
  let isEmailValid = PassthroughSubject<Bool, Never>()
  let emailVerificationMode = PassthroughSubject<SendReceiptMode, Never>()
  let verifyEmail = PassthroughSubject<Void, Never>()
  let emailVerified = PassthroughSubject<String, Never>()
  
  let manager: NetworkManager
  var userEmail: String { return needToVerifyEmail ?? "" }
  var verifyEmailMode: VerifyEmailMode { return verifiedEmail == nil ? .verify : .update }
  let onUpdate: ((TLUpdateCallback) -> Void)?
  let onError: ((TLErrorCallback) -> Void)?
  private(set) lazy var onEmailVerified: (VerifyEmailMode) -> Void = { [weak self] in
    self?.didVerifyEmail(with: $0)
  }
  private let transactionId: String
  private let onEmailSent: () -> Void
  private var verifiedEmail: String?
  private var needToVerifyEmail: String? {
    didSet {
      guard needToVerifyEmail != nil else { return }
      verifyEmail.send()
    }
  }
  private var emailVerificationModeModel: SendReceiptMode = .notVerified {
    didSet {
      emailVerificationMode.send(emailVerificationModeModel)
    }
  }
  
  init(transactionId: String,
       manager: NetworkManager,
       onEmailSent: @escaping () -> Void,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    self.transactionId = transactionId
    self.manager = manager
    self.onEmailSent = onEmailSent
    self.onUpdate = onUpdate
    self.onError = onError
  }
  
  func load() {
    loading.send(true)
    manager.getUserInfo { [weak self] result in
      guard let self = self else { return }
      self.loading.send(false)
      switch result {
      case .success(let model):
        model.email.map {
          self.verifiedEmail = $0
          self.defaultEmail.send($0)
          self.checkEmail($0)
        }
        self.emailVerificationModeModel = model.isEmailVerified ? .verified : .notVerified
      case .failure(let error):
        self.didFail(with: .init(error: error, value: true))
      }
    }
  }
  
  func checkEmail(_ email: String) {
    isEmailValid.send(SendReceiptValidator.isEmailValid(email))
  }
  
  func sendEmail(_ email: String) {
    switch emailVerificationModeModel {
    case .notVerified:
      needToVerifyEmail = email
    case .verified:
      sending.send(true)
      manager.sendTransactionReceipt(withId: transactionId, email: email) { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .success:
          self.emailSent.send()
        case .failure(let error):
          self.sending.send(false)
          self.didFail(with: .init(error: error, value: false))
        }
      }
    case .edit:
      if email == verifiedEmail {
        emailVerificationModeModel = .verified
      } else {
        needToVerifyEmail = email
      }
    }
    
  }
  
  func editEmail() {
    emailVerificationModeModel = .edit
  }
  
  func cancelEditEmail(_ email: String) {
    if email != verifiedEmail {
      verifiedEmail.map { defaultEmail.send($0) }
    }
    emailVerificationModeModel = .verified
  }
  
  func complete() {
    onEmailSent()
  }
  
}

// MARK: - Private Methods

private extension SendReceiptViewModel {
  
  func didFail(with error: ErrorWithBoolModel) {
    self.error.send(error)
    let event = TLEvent(flow: .transactionDetails, action: .error)
    let model = TLErrorCallback(event: event,
                                error: L.errorSendReceiptTitle,
                                message: error.error.localizedDescription)
    onError?(model)
  }
  
  func didVerifyEmail(with mode: VerifyEmailMode) {
    verifiedEmail = needToVerifyEmail
    needToVerifyEmail = nil
    emailVerificationModeModel = .verified
    emailVerified.send(mode.successTitle)
  }
  
}
