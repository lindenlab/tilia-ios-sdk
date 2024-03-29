//
//  TosViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.03.2022.
//

import Combine

protocol TosViewModelInputProtocol {
  func acceptTos()
  func complete()
}

protocol TosViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var accept: CurrentValueSubject<Bool, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
}

protocol TosDataStore {
  var manager: NetworkManager { get }
  var onTosContentError: ((TLErrorCallback) -> Void)? { get }
}

protocol TosViewModelProtocol: TosViewModelInputProtocol, TosViewModelOutputProtocol { }

final class TosViewModel: TosViewModelProtocol, TosDataStore {
  
  let loading = PassthroughSubject<Bool, Never>()
  let accept = CurrentValueSubject<Bool, Never>(false)
  let error = PassthroughSubject<Error, Never>()
  
  let manager: NetworkManager
  var onTosContentError: ((TLErrorCallback) -> Void)? {
    return onError
  }
  
  private let onComplete: ((TLCompleteCallback) -> Void)?
  private let onError: ((TLErrorCallback) -> Void)?
  
  init(manager: NetworkManager,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    self.manager = manager
    self.onComplete = onComplete
    self.onError = onError
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
        self.didFail(with: error)
      }
    }
  }
  
  func complete() {
    let isAccepted = accept.value
    let event = TLEvent(flow: .tos,
                        action: isAccepted ? .completed : .cancelledByUser)
    let model = TLCompleteCallback(event: event,
                                   state: isAccepted ? .completed : .cancelled)
    onComplete?(model)
  }
  
}

// MARK: - Private Methods

private extension TosViewModel {
  
  func didFail(with error: Error) {
    let event = TLEvent(flow: .tos, action: .error)
    let model = TLErrorCallback(event: event,
                                error: L.errorTosTitle,
                                message: error.localizedDescription)
    onError?(model)
  }
  
}
