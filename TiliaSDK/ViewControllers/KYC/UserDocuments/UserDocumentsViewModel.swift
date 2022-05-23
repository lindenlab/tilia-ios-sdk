//
//  UserDocumentsViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 17.05.2022.
//

import Combine
import Foundation

protocol UserDocumentsViewModelInputProtocol {
  func viewDidLoad()
}

protocol UserDocumentsViewModelOutputProtocol {
  var error: PassthroughSubject<Error, Never> { get }
  var content: PassthroughSubject<Void, Never> { get }
}

protocol UserDocumentsViewModelProtocol: UserDocumentsViewModelInputProtocol, UserDocumentsViewModelOutputProtocol { }

final class UserDocumentsViewModel: UserDocumentsViewModelProtocol {
  
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
