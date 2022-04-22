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
  private var needToReload = false
  
  init(manager: NetworkManager,
       onReload: @escaping (Bool) -> Void) {
    self.manager = manager
    self.onReload = onReload
  }
  
  func openBrowser() {
    // TODO: - Added here logic for getting url
    loading.send(true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.loading.send(false)
      self.needToReload = true
    }
  }
  
  func complete() {
    onReload(needToReload)
  }
  
}
