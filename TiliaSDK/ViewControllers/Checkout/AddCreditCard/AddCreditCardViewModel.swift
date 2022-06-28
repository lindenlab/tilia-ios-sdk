//
//  AddCreditCardViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.04.2022.
//

import Foundation
import Combine

protocol AddCreditCardViewModelInputProtocol {
  func openBrowser()
  func complete()
}

protocol AddCreditCardViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
  var openUrl: PassthroughSubject<URL, Never> { get }
}

protocol AddCreditCardViewModelProtocol: AddCreditCardViewModelInputProtocol, AddCreditCardViewModelOutputProtocol { }

final class AddCreditCardViewModel: AddCreditCardViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<Error, Never>()
  let openUrl = PassthroughSubject<URL, Never>()
  
  private let manager: NetworkManager
  private let onReload: (Bool) -> Void
  private let onError: ((TLErrorCallback) -> Void)?
  private var needToReload = false
  
  init(manager: NetworkManager,
       onReload: @escaping (Bool) -> Void,
       onError: ((TLErrorCallback) -> Void)?) {
    self.manager = manager
    self.onReload = onReload
    self.onError = onError
  }
  
  func openBrowser() {
    loading.send(true)
    manager.getAddCreditCardRedirectUrl { [weak self] result in
      guard let self = self else { return }
      self.loading.send(false)
      switch result {
      case .success(let model):
        self.needToReload = true
        self.openUrl.send(model.url)
      case .failure(let error):
        self.error.send(error)
        let event = TLEvent(flow: .checkout, action: .error)
        let model = TLErrorCallback(event: event,
                                    error: L.addCreditCardTitle,
                                    message: error.localizedDescription)
        self.onError?(model)
      }
    }
  }
  
  func complete() {
    onReload(needToReload)
  }
  
}
