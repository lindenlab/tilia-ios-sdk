//
//  UserInfoViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import Combine

protocol UserInfoViewModelInputProtocol {
  func viewDidLoad()
}

protocol UserInfoViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
  var content: PassthroughSubject<Void, Never> { get }
}

protocol UserInfoViewModelProtocol: UserInfoViewModelInputProtocol, UserInfoViewModelOutputProtocol {
  
}

final class UserInfoViewModel: UserInfoViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<Error, Never>()
  let content = PassthroughSubject<Void, Never>()
  
  private let manager: NetworkManager
  
  init(manager: NetworkManager) {
    self.manager = manager
  }
  
  func viewDidLoad() {
    content.send(())// TODO: - Fix this
  }
  
}
