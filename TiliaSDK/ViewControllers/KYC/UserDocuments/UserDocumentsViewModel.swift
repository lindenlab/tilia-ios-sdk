//
//  UserDocumentsViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 17.05.2022.
//

import Combine
import UIKit
import PDFKit

typealias UserDocumentsSetText = (index: Int, text: String?)
typealias UserDocumentsSetImage = (index: Int, image: UIImage?)
typealias UserDocumentsDocumentCountryDidChange = (model: UserDocumentsModel, wasUsResidence: Bool)
typealias UserDocumentsAddDocument = (index: Int, document: PDFDocument?)
typealias UserDocumentsDeleteDocument = (itemIndex: Int, documentIndex: Int)

protocol UserDocumentsViewModelInputProtocol {
  func viewDidLoad()
  func setText(_ text: String?, for item: UserDocumentsSectionBuilder.Section.Item, at index: Int)
  func setImage(_ image: UIImage?, for item: UserDocumentsSectionBuilder.Section.Item, at index: Int, with url: URL?)
  func setFiles(with urls: [URL])
  func deleteDocument(forItemIndex itemIndex: Int, atDocumentIndex documentIndex: Int)
}

protocol UserDocumentsViewModelOutputProtocol {
  var error: PassthroughSubject<Error, Never> { get }
  var content: PassthroughSubject<UserDocumentsModel, Never> { get }
  var setText: PassthroughSubject<UserDocumentsSetText, Never> { get }
  var setImage: PassthroughSubject<UserDocumentsSetImage, Never> { get }
  var documentDidSelect: PassthroughSubject<UserDocumentsModel, Never> { get }
  var documentDidChange: PassthroughSubject<UserDocumentsModel.Document, Never> { get }
  var documentCountryDidChange: PassthroughSubject<UserDocumentsDocumentCountryDidChange, Never> { get }
  var isAddressOnDocumentDidChange: PassthroughSubject<BoolModel, Never> { get }
  var addDocument: PassthroughSubject<UserDocumentsAddDocument, Never> { get }
  var deleteDocument: PassthroughSubject<UserDocumentsDeleteDocument, Never> { get }
}

protocol UserDocumentsViewModelProtocol: UserDocumentsViewModelInputProtocol, UserDocumentsViewModelOutputProtocol { }

final class UserDocumentsViewModel: UserDocumentsViewModelProtocol {
  
  let error = PassthroughSubject<Error, Never>()
  let content = PassthroughSubject<UserDocumentsModel, Never>()
  let setText = PassthroughSubject<UserDocumentsSetText, Never>()
  let setImage = PassthroughSubject<UserDocumentsSetImage, Never>()
  let documentDidSelect = PassthroughSubject<UserDocumentsModel, Never>()
  let documentDidChange = PassthroughSubject<UserDocumentsModel.Document, Never>()
  let documentCountryDidChange = PassthroughSubject<UserDocumentsDocumentCountryDidChange, Never>()
  let isAddressOnDocumentDidChange = PassthroughSubject<BoolModel, Never>()
  let addDocument = PassthroughSubject<UserDocumentsAddDocument, Never>()
  let deleteDocument = PassthroughSubject<UserDocumentsDeleteDocument, Never>()
  
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
      let wasUsResidence = userDocumentsModel.isUsResident
      isFieldChanged = isFieldUpdated(&userDocumentsModel.documentCountry, with: text ?? "")
      
      if isFieldChanged {
        if wasUsResidence {
          userDocumentsModel.isAddressOnDocument = nil
        }
        documentCountryDidChange.send((userDocumentsModel, wasUsResidence))
      }
    case .isAddressOnDocument:
      let value = BoolModel(str: text ?? "")
      isFieldChanged = isFieldUpdated(&userDocumentsModel.isAddressOnDocument, with: value)
      if isFieldChanged, let value = value {
        isAddressOnDocumentDidChange.send(value)
      }
    }
    
    if isFieldChanged {
      setText.send((index, text))
    }
  }
  
  func setImage(_ image: UIImage?, for item: UserDocumentsSectionBuilder.Section.Item, at index: Int, with url: URL?) {
    switch item.mode {
    case let .photo(model):
      switch model.type {
      case .frontSide:
        userDocumentsModel.frontImage = image
      case .backSide:
        userDocumentsModel.backImage = image
      }
      setImage.send((index, image))
      url.map { deleteTempFile(at: $0) }
    case .additionalDocuments:
      let document = pdfDocument(from: image)
      addDocument.send((index, document))
    default:
      break
    }
  }
  
  func setFiles(with urls: [URL]) {
    
  }
  
  func deleteDocument(forItemIndex itemIndex: Int, atDocumentIndex documentIndex: Int) {
    deleteDocument.send((itemIndex, documentIndex))
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
    DispatchQueue.global().async {
      try? FileManager.default.removeItem(at: url)
    }
  }
  
  func pdfDocument(from image: UIImage?) -> PDFDocument? {
    guard
      let image = image,
        let page = PDFPage(image: image) else { return nil }
    let document = PDFDocument()
    document.insert(page, at: document.pageCount)
    return document
  }
  
}
