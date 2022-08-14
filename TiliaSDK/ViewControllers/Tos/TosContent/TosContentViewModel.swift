//
//  TosContentViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 12.08.2022.
//

import Combine

protocol TosContentViewModelInputProtocol {
  func loadContent()
}

protocol TosContentViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
  var content: PassthroughSubject<String, Never> { get }
}

protocol TosContentViewModelProtocol: TosContentViewModelInputProtocol, TosContentViewModelOutputProtocol { }

final class TosContentViewModel: TosContentViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<Error, Never>()
  let content = PassthroughSubject<String, Never>()
  
  private let manager: NetworkManager
  private let onError: ((TLErrorCallback) -> Void)?
  
  init(manager: NetworkManager,
       onError: ((TLErrorCallback) -> Void)?) {
    self.manager = manager
    self.onError = onError
  }
  
  func loadContent() {
    loading.send(true)
    manager.getTosContent { [weak self] result in
      guard let self = self else { return }
      self.loading.send(false)
      switch result {
      case .success(let model):
        self.content.send(model.content)
      case .failure(let error):
        self.error.send(error)
        self.didFail(with: error)
      }
    }
  }
  
}

// MARK: - Private Methods

private extension TosContentViewModel {
  
  func didFail(with error: Error) {
    let event = TLEvent(flow: .tos, action: .error)
    let model = TLErrorCallback(event: event,
                                error: L.errorTosContentTitle,
                                message: error.localizedDescription)
    onError?(model)
  }
  
}
