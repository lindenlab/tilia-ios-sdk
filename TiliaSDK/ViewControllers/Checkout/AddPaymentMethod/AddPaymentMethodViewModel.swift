//
//  AddPaymentMethodViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.04.2022.
//

import Foundation
import Combine

protocol AddPaymentMethodViewModelInputProtocol {
  func openBrowser()
  func complete()
}

protocol AddPaymentMethodViewModelOutputProtocol {
  var mode: AddPaymentMethodMode { get }
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
  var openUrl: PassthroughSubject<URL, Never> { get }
}

protocol AddPaymentMethodViewModelProtocol: AddPaymentMethodViewModelInputProtocol, AddPaymentMethodViewModelOutputProtocol { }

final class AddPaymentMethodViewModel: AddPaymentMethodViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<Error, Never>()
  let openUrl = PassthroughSubject<URL, Never>()
  
  let mode: AddPaymentMethodMode
  private let manager: NetworkManager
  private let onReload: () -> Void
  private let onError: ((TLErrorCallback) -> Void)?
  private var needToReload = false
  
  init(manager: NetworkManager,
       mode: AddPaymentMethodMode,
       onReload: @escaping () -> Void,
       onError: ((TLErrorCallback) -> Void)?) {
    self.manager = manager
    self.mode = mode
    self.onReload = onReload
    self.onError = onError
  }
  
  func openBrowser() {
    loading.send(true)
    manager.getAddPaymentMethodRedirectUrl(for: mode) { [weak self] result in
      guard let self = self else { return }
      self.loading.send(false)
      switch result {
      case .success(let model):
        self.needToReload = true
        self.openUrl.send(model.url)
      case .failure(let error):
        self.error.send(error)
        self.didFail(with: error)
      }
    }
  }
  
  func complete() {
    guard needToReload else { return }
    onReload()
  }
  
}

// MARK: - Private Methods

private extension AddPaymentMethodViewModel {
  
  func didFail(with error: Error) {
    let event = TLEvent(flow: .checkout, action: .error)
    let model = TLErrorCallback(event: event,
                                error: mode.title,
                                message: error.localizedDescription)
    onError?(model)
  }
  
}
