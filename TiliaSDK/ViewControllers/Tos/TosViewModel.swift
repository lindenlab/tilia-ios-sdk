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
  var accept: PassthroughSubject<Void, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
}

protocol TosViewModelProtocol: TosViewModelInputProtocol, TosViewModelOutputProtocol { }

final class TosViewModel: TosViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let accept = PassthroughSubject<Void, Never>()
  let error = PassthroughSubject<Error, Never>()
  
  func acceptTos() {
    loading.send(true)
    TLManager.shared.getTosRequiredForUser { result in
      self.loading.send(false)
      switch result {
      case .success(let model):
        if model.isTosSigned {
          self.accept.send(())
        } else {
          self.error.send(TLError.tosIsNotSigned)
        }
      case .failure(let error):
        self.error.send(error)
      }
    }
  }
  
}
