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
typealias UserDocumentsAddDocuments = (index: Int, documentImages: [UIImage])
typealias UserDocumentsDeleteDocument = (itemIndex: Int, documentIndex: Int)

protocol UserDocumentsViewModelInputProtocol {
  func viewDidLoad()
  func setText(_ text: String?, for item: UserDocumentsSectionBuilder.Section.Item, at index: Int)
  func setImage(_ image: UIImage?, for item: UserDocumentsSectionBuilder.Section.Item, at index: Int, with url: URL?)
  func setFiles(with urls: [URL], at index: Int)
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
  var addDocuments: PassthroughSubject<UserDocumentsAddDocuments, Never> { get }
  var addDocumentsDidFail: PassthroughSubject<Void, Never> { get }
  var deleteDocument: PassthroughSubject<UserDocumentsDeleteDocument, Never> { get }
  var fillingContent: PassthroughSubject<Bool, Never> { get }
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
  let addDocuments = PassthroughSubject<UserDocumentsAddDocuments, Never>()
  let addDocumentsDidFail = PassthroughSubject<Void, Never>()
  let deleteDocument = PassthroughSubject<UserDocumentsDeleteDocument, Never>()
  let fillingContent = PassthroughSubject<Bool, Never>()
  
  private let manager: NetworkManager
  private var userDocumentsModel: UserDocumentsModel
  private let processQueue = DispatchQueue(label: "io.tilia.ios.sdk.userDocumentsProcessQueue", attributes: .concurrent)
  
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
        } else if userDocumentsModel.isUsResident {
          userDocumentsModel.additionalDocuments.removeAll()
        }
        documentCountryDidChange.send((userDocumentsModel, wasUsResidence))
      }
    case .isAddressOnDocument:
      let value = BoolModel(str: text ?? "")
      isFieldChanged = isFieldUpdated(&userDocumentsModel.isAddressOnDocument, with: value)
      if isFieldChanged, let value = value {
        if value == .yes {
          userDocumentsModel.additionalDocuments.removeAll()
        }
        isAddressOnDocumentDidChange.send(value)
      }
    }
    
    if isFieldChanged {
      setText.send((index, text))
      updateFillingSectionObserver()
    }
  }
  
  func setImage(_ image: UIImage?, for item: UserDocumentsSectionBuilder.Section.Item, at index: Int, with url: URL?) {
    let resizedImage = resizedImage(image)
    switch item.mode {
    case let .photo(model):
      switch model.type {
      case .frontSide:
        userDocumentsModel.frontImage = resizedImage
      case .backSide:
        userDocumentsModel.backImage = resizedImage
      }
      setImage.send((index, resizedImage))
    case .additionalDocuments:
      resizedImage.map {
        userDocumentsModel.additionalDocuments.append(.image($0))
        addDocuments.send((index, [$0]))
      }
    default:
      break
    }
    url.map { deleteTempFile(at: $0) }
    updateFillingSectionObserver()
  }
  
  func setFiles(with urls: [URL], at index: Int) {
    var addDocumentsFailed = false
    var documentImages: [UIImage] = []
    urls.forEach { url in
      PDFDocument(url: url).map { document in
        if !document.isLocked {
          userDocumentsModel.additionalDocuments.append(.pdfFile(document))
          image(from: document).map { documentImages.append($0) }
        } else {
          addDocumentsFailed = true
        }
      }
      deleteTempFile(at: url)
    }
    if !documentImages.isEmpty {
      addDocuments.send((index, documentImages))
      updateFillingSectionObserver()
    }
    if addDocumentsFailed {
      addDocumentsDidFail.send(())
    }
  }
  
  func deleteDocument(forItemIndex itemIndex: Int, atDocumentIndex documentIndex: Int) {
    userDocumentsModel.additionalDocuments.remove(at: documentIndex)
    deleteDocument.send((itemIndex, documentIndex))
    updateFillingSectionObserver()
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
    processQueue.async {
      try? FileManager.default.removeItem(at: url)
    }
  }
  
  func image(from document: PDFDocument) -> UIImage? {
    processQueue.sync {
      guard let page = document.page(at: 0) else { return nil }
      let pageRect = page.bounds(for: .mediaBox)
      return page.thumbnail(of: pageRect.size, for: .mediaBox)
    }
  }
  
  func resizedImage(_ image: UIImage?) -> UIImage? {
    processQueue.sync {
      guard let image = image else { return image }
      
      let newSize = CGSize(width: 1024, height: 1024)
      var imageSize = image.size
      guard imageSize.width > newSize.width || imageSize.height > newSize.height else { return image }
      
      let ratio = max(imageSize.width / newSize.width, imageSize.height / newSize.height)
      imageSize.width = imageSize.width / ratio
      imageSize.height = imageSize.height / ratio
      let renderer = UIGraphicsImageRenderer(size: imageSize)
      return renderer.image { _ in
        image.draw(in: .init(origin: .zero, size: imageSize))
      }
    }
  }
  
  func updateFillingSectionObserver() {
    let isSectionFilled = UserDocumentsValidator.isFilled(for: userDocumentsModel)
    fillingContent.send(isSectionFilled)
  }
  
}
