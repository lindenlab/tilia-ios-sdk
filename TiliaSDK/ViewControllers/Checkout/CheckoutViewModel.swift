//
//  CheckoutViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import Combine

protocol CheckoutViewModelInputProtocol {
  func checkIsTosRequired()
  func proceedCheckout()
}

protocol CheckoutViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
  var needToAcceptTos: PassthroughSubject<Void, Never> { get }
}

protocol CheckoutViewModelProtocol: CheckoutViewModelInputProtocol, CheckoutViewModelOutputProtocol { }

final class CheckoutViewModel: CheckoutViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<Error, Never>()
  let needToAcceptTos = PassthroughSubject<Void, Never>()
  
  private let invoiceId: String
  private let manager = TLManager.shared
  
  init(invoiceId: String) {
    self.invoiceId = invoiceId
  }
  
  func checkIsTosRequired() {
    loading.send(true)
    manager.getTosRequiredForUser { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let isTosSigned):
        if !isTosSigned {
          self.needToAcceptTos.send(())
        } else {
          self.proceedCheckout()
        }
      case .failure(let error):
        self.loading.send(false)
        self.error.send(error)
      }
    }
  }
  
  func proceedCheckout() {
    
  }
  
}
