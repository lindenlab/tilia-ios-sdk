//
//  UserDocumentsViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 17.05.2022.
//

import Combine
import UIKit

typealias UserDocumentsSetText = (index: Int, text: String?)
typealias UserDocumentsSetImage = (index: Int, image: UIImage?)

protocol UserDocumentsViewModelInputProtocol {
  func viewDidLoad()
  func setText(_ text: String?, for item: UserDocumentsSectionBuilder.Section.Item, at index: Int)
  func setImage(_ image: UIImage?, for item: UserDocumentsSectionBuilder.Section.Item, at index: Int, with url: URL?)
  func setFiles(with urls: [URL])
}

protocol UserDocumentsViewModelOutputProtocol {
  var error: PassthroughSubject<Error, Never> { get }
  var content: PassthroughSubject<UserDocumentsModel, Never> { get }
  var setText: PassthroughSubject<UserDocumentsSetText, Never> { get }
  var setImage: PassthroughSubject<UserDocumentsSetImage, Never> { get }
  var documentDidSelect: PassthroughSubject<UserDocumentsModel, Never> { get }
  var documentDidChange: PassthroughSubject<UserDocumentsModel.Document, Never> { get }
}

protocol UserDocumentsViewModelProtocol: UserDocumentsViewModelInputProtocol, UserDocumentsViewModelOutputProtocol { }

final class UserDocumentsViewModel: UserDocumentsViewModelProtocol {
  
  let error = PassthroughSubject<Error, Never>()
  let content = PassthroughSubject<UserDocumentsModel, Never>()
  let setText = PassthroughSubject<UserDocumentsSetText, Never>()
  let setImage = PassthroughSubject<UserDocumentsSetImage, Never>()
  let documentDidSelect = PassthroughSubject<UserDocumentsModel, Never>()
  let documentDidChange = PassthroughSubject<UserDocumentsModel.Document, Never>()
  
  private let manager: NetworkManager
  private var userDocumentsModel: UserDocumentsModel
  
  init(manager: NetworkManager, defaultCounty: String) {
    self.manager = manager
    self.userDocumentsModel = UserDocumentsModel(documentCountry: defaultCounty)
  }
  
  func viewDidLoad() {
    content.send(userDocumentsModel)// TODO: - Fix this
  }
  
  func setText(_ text: String?, for item: UserDocumentsSectionBuilder.Section.Item, at index: Int) {
    guard case let .field(field) = item.mode else { return }
    
    var isFieldChanged = false
    
    switch field.type {
    case .document:
      let wasNil = userDocumentsModel.document == nil
      let value = UserDocumentsModel.Document(str: text ?? "")
      isFieldChanged = isFieldUpdated(&userDocumentsModel.document, with: value)
      if wasNil {
        documentDidSelect.send(userDocumentsModel)
      } else if isFieldChanged, let value = value {
        userDocumentsModel.setImagesToDefault()
        documentDidChange.send(value)
      }
    case .documentCountry:
      isFieldChanged = isFieldUpdated(&userDocumentsModel.documentCountry, with: text ?? "")
    case .isAddressOnDocument:
      let value = BoolModel(str: text ?? "")
      isFieldChanged = isFieldUpdated(&userDocumentsModel.isAddressOnDocument, with: value)
    }
    
    if isFieldChanged {
      setText.send((index, text))
    }
  }
  
  func setImage(_ image: UIImage?, for item: UserDocumentsSectionBuilder.Section.Item, at index: Int, with url: URL?) {
    guard case let .photo(model) = item.mode else { return }
    switch model.type {
    case .frontSide:
      userDocumentsModel.frontImage = image
    case .backSide:
      userDocumentsModel.backImage = image
    }
    setImage.send((index, image))
    url.map { deleteTempFile(at: $0) }
  }
  
  func setFiles(with urls: [URL]) {
    
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsViewModel {
  
  func isFieldUpdated<Value: Equatable>(_ field: inout Value, with value: Value) -> Bool {
    guard field != value else { return false }
    field = value
    return true
  }
  
  func deleteTempFile(at url: URL) {
    // TODO: - Add here queue
    try? FileManager.default.removeItem(at: url)
  }
  
}
