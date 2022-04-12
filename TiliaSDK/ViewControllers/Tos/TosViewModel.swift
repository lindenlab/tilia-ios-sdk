//
//  TosViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.03.2022.
//

import Combine

protocol TosViewModelInputProtocol {
  func acceptTos()
}

protocol TosViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var accept: CurrentValueSubject<Bool, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
}

protocol TosViewModelProtocol: TosViewModelInputProtocol, TosViewModelOutputProtocol { }

final class TosViewModel: TosViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let accept = CurrentValueSubject<Bool, Never>(false)
  let error = PassthroughSubject<Error, Never>()
  
  private let manager: NetworkManager
  
  init(manager: NetworkManager) {
    self.manager = manager
  }
  
  func acceptTos() {
    loading.send(true)
    manager.signTosForUser { [weak self] result in
      guard let self = self else { return }
      self.loading.send(false)
      switch result {
      case .success:
        self.accept.send(true)
      case .failure(let error):
        self.error.send(error)
      }
    }
  }
  
}
