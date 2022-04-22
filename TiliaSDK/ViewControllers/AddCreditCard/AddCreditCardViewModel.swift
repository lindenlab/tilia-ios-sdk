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
}

protocol AddCreditCardViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
  var openUrl: PassthroughSubject<URL, Never> { get }
  var needToReload: Bool { get }
}

protocol AddCreditCardViewModelProtocol: AddCreditCardViewModelInputProtocol, AddCreditCardViewModelOutputProtocol { }

final class AddCreditCardViewModel: AddCreditCardViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<Error, Never>()
  let openUrl = PassthroughSubject<URL, Never>()
  private(set) var needToReload = false
  
  private let manager: NetworkManager
  
  init(manager: NetworkManager) {
    self.manager = manager
  }
  
  func openBrowser() {
    // TODO: - Added here logic for getting url
    loading.send(true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.loading.send(false)
      self.needToReload = true
    }
  }
  
}
