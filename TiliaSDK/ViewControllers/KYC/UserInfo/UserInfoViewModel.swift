//
//  UserInfoViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import Combine

protocol UserInfoViewModelInputProtocol {
  
}

protocol UserInfoViewModelOutputProtocol {
  
}

protocol UserInfoViewModelProtocol: UserInfoViewModelInputProtocol, UserInfoViewModelOutputProtocol {
  
}

final class UserInfoViewModel: UserInfoViewModelProtocol {
  
  private let manager: NetworkManager
  
  init(manager: NetworkManager) {
    self.manager = manager
  }
  
}
