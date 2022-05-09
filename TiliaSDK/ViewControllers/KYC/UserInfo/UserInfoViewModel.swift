//
//  UserInfoViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import Combine

typealias UserInfoSection = (index: Int, isExpanded: Bool, model: UserInfoModel)

protocol UserInfoViewModelInputProtocol {
  func viewDidLoad()
  func updateSection(at index: Int, isExpanded: Bool)
}

protocol UserInfoViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
  var content: PassthroughSubject<Void, Never> { get }
  var section: PassthroughSubject<UserInfoSection, Never> { get }
}

protocol UserInfoViewModelProtocol: UserInfoViewModelInputProtocol, UserInfoViewModelOutputProtocol {
  
}

final class UserInfoViewModel: UserInfoViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<Error, Never>()
  let content = PassthroughSubject<Void, Never>()
  let section = PassthroughSubject<UserInfoSection, Never>()
  
  private let manager: NetworkManager
  private var userInfoModel = UserInfoModel()
  
  init(manager: NetworkManager) {
    self.manager = manager
  }
  
  func viewDidLoad() {
    content.send(())// TODO: - Fix this
  }
  
  func updateSection(at index: Int, isExpanded: Bool) {
    section.send((index, isExpanded, userInfoModel))
  }
  
}
