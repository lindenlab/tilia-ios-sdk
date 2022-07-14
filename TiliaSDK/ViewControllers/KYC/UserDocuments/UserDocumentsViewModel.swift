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
typealias UserDocumentsSetDocumentImage = (index: Int, image: UIImage?)
typealias UserDocumentsDocumentCountryDidChange = (model: UserDocumentsModel, wasUsDocumentCountry: Bool)
typealias UserDocumentsAddAdditionalDocuments = (index: Int, documentImages: [UIImage])
typealias UserDocumentsDeleteAdditionalDocument = (itemIndex: Int, documentIndex: Int)

protocol UserDocumentsViewModelInputProtocol {
  func setText(_ text: String?, for item: UserDocumentsSectionBuilder.Section.Item, at index: Int)
  func setImage(_ image: UIImage?, for item: UserDocumentsSectionBuilder.Section.Item, at index: Int, with url: URL?)
  func setFiles(with urls: [URL], at index: Int)
  func deleteDocument(forItemIndex itemIndex: Int, atDocumentIndex documentIndex: Int)
  func upload()
  func complete()
}

protocol UserDocumentsViewModelOutputProtocol {
  var error: PassthroughSubject<Error, Never> { get }
  var setText: PassthroughSubject<UserDocumentsSetText, Never> { get }
  var setDocumentImage: PassthroughSubject<UserDocumentsSetDocumentImage, Never> { get }
  var documentDidSelect: PassthroughSubject<UserDocumentsModel, Never> { get }
  var documentDidChange: PassthroughSubject<UserDocumentsModel.Document, Never> { get }
  var documentCountryDidChange: PassthroughSubject<UserDocumentsDocumentCountryDidChange, Never> { get }
  var isAddressOnDocumentDidChange: PassthroughSubject<BoolModel, Never> { get }
  var addAdditionalDocuments: PassthroughSubject<UserDocumentsAddAdditionalDocuments, Never> { get }
  var addAdditionalDocumentsDidFail: PassthroughSubject<Void, Never> { get }
  var deleteAdditionalDocument: PassthroughSubject<UserDocumentsDeleteAdditionalDocument, Never> { get }
  var fillingContent: PassthroughSubject<Bool, Never> { get }
  var uploading: CurrentValueSubject<Bool, Never> { get }
  var successfulUploading: PassthroughSubject<Void, Never> { get }
  var waiting: PassthroughSubject<Void, Never> { get }
  var successfulWaiting: PassthroughSubject<Void, Never> { get }
}

protocol UserDocumentsViewModelProtocol: UserDocumentsViewModelInputProtocol, UserDocumentsViewModelOutputProtocol { }

final class UserDocumentsViewModel: UserDocumentsViewModelProtocol {
  
  let error = PassthroughSubject<Error, Never>()
  let setText = PassthroughSubject<UserDocumentsSetText, Never>()
  let setDocumentImage = PassthroughSubject<UserDocumentsSetDocumentImage, Never>()
  let documentDidSelect = PassthroughSubject<UserDocumentsModel, Never>()
  let documentDidChange = PassthroughSubject<UserDocumentsModel.Document, Never>()
  let documentCountryDidChange = PassthroughSubject<UserDocumentsDocumentCountryDidChange, Never>()
  let isAddressOnDocumentDidChange = PassthroughSubject<BoolModel, Never>()
  let addAdditionalDocuments = PassthroughSubject<UserDocumentsAddAdditionalDocuments, Never>()
  let addAdditionalDocumentsDidFail = PassthroughSubject<Void, Never>()
  let deleteAdditionalDocument = PassthroughSubject<UserDocumentsDeleteAdditionalDocument, Never>()
  let fillingContent = PassthroughSubject<Bool, Never>()
  let uploading = CurrentValueSubject<Bool, Never>(false)
  let successfulUploading = PassthroughSubject<Void, Never>()
  let waiting = PassthroughSubject<Void, Never>()
  let successfulWaiting = PassthroughSubject<Void, Never>()
  
  private let manager: NetworkManager
  private let userInfoModel: UserInfoModel
  private var userDocumentsModel: UserDocumentsModel
  private let onComplete: ((Bool) -> Void)
  private let onError: ((Error) -> Void)?
  private let processQueue = DispatchQueue(label: "io.tilia.ios.sdk.userDocumentsProcessQueue", attributes: .concurrent)
  private var isUploaded = false
  private var timer: Timer?
  
  init(manager: NetworkManager,
       userInfoModel: UserInfoModel,
       onComplete: @escaping (Bool) -> Void,
       onError: ((Error) -> Void)?) {
    self.manager = manager
    self.userInfoModel = userInfoModel
    self.userDocumentsModel = UserDocumentsModel(model: userInfoModel)
    self.onComplete = onComplete
    self.onError = onError
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
        userDocumentsModel.setDocumentImagesToDefault()
        documentDidChange.send(value)
      }
    case .documentCountry:
      if userDocumentsModel.documentCountry?.name != text {
        let wasUsDocumentCountry = userDocumentsModel.isUsDocumentCountry
        isFieldChanged = true
        userDocumentsModel.documentCountry = CountryModel.countries.first { $0.name == text }
        if wasUsDocumentCountry {
          userDocumentsModel.isAddressOnDocument = nil
        } else if userDocumentsModel.isUsDocumentCountry {
          userDocumentsModel.additionalDocuments.removeAll()
        }
        documentCountryDidChange.send((userDocumentsModel, wasUsDocumentCountry))
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
    resizedImage(image) { resizedImage in
      switch item.mode {
      case let .photo(model):
        switch model.type {
        case .frontSide:
          self.userDocumentsModel.frontImage = resizedImage
        case .backSide:
          self.userDocumentsModel.backImage = resizedImage
        }
        self.setDocumentImage.send((index, resizedImage))
      case .additionalDocuments:
        resizedImage.map {
          self.userDocumentsModel.additionalDocuments.append(.image($0))
          self.addAdditionalDocuments.send((index, [$0]))
        }
      default:
        break
      }
      self.updateFillingSectionObserver()
    }
    url.map { deleteTempFile(at: $0) }
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
      addAdditionalDocuments.send((index, documentImages))
      updateFillingSectionObserver()
    }
    if addDocumentsFailed {
      addAdditionalDocumentsDidFail.send()
    }
  }
  
  func deleteDocument(forItemIndex itemIndex: Int, atDocumentIndex documentIndex: Int) {
    userDocumentsModel.additionalDocuments.remove(at: documentIndex)
    deleteAdditionalDocument.send((itemIndex, documentIndex))
    updateFillingSectionObserver()
  }
  
  func upload() {
    uploading.send(true)
    submitModel() { [weak self] submitModel in
      guard let self = self else { return }
      self.manager.submitKyc(with: submitModel) { result in
        self.uploading.send(false)
        switch result {
        case .success(let model):
          self.isUploaded = true
          self.successfulUploading.send()
          self.resumeTimer(kycId: model.kycId)
        case .failure(let error):
          self.error.send(error)
        }
      }
    }
  }
  
  func complete() {
    onComplete(isUploaded)
  }
  
  deinit {
    timer?.invalidate()
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
    guard let page = document.page(at: 0) else { return nil }
    let pageRect = page.bounds(for: .mediaBox)
    return page.thumbnail(of: pageRect.size, for: .mediaBox)
  }
  
  func resizedImage(_ image: UIImage?, completion: @escaping (UIImage?) -> Void) {
    processQueue.async {
      guard let image = image else {
        DispatchQueue.main.async { completion(image) }
        return
      }
      let newSize = CGSize(width: 1024, height: 1024)
      var imageSize = image.size
      guard imageSize.width > newSize.width || imageSize.height > newSize.height else {
        DispatchQueue.main.async { completion(image) }
        return
      }
      
      let ratio = max(imageSize.width / newSize.width, imageSize.height / newSize.height)
      imageSize.width = imageSize.width / ratio
      imageSize.height = imageSize.height / ratio
      let renderer = UIGraphicsImageRenderer(size: imageSize)
      let newImage = renderer.image { _ in
        image.draw(in: .init(origin: .zero, size: imageSize))
      }
      DispatchQueue.main.async { completion(newImage) }
    }
  }
  
  func submitModel(completion: @escaping (SubmitKycModel) -> Void) {
    processQueue.async {
      let model = SubmitKycModel(userInfoModel: self.userInfoModel,
                                 userDocumentsModel: self.userDocumentsModel)
      DispatchQueue.main.async { completion(model) }
    }
  }
  
  func updateFillingSectionObserver() {
    let isSectionFilled = UserDocumentsValidator.isFilled(for: userDocumentsModel)
    fillingContent.send(isSectionFilled)
  }
  
  func resumeTimer(kycId: String) {
    timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
      guard let self = self else { return }
      self.waiting.send()
      self.getSubmittedStatus(for: kycId)
    }
  }
  
  func invalidateTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  func getSubmittedStatus(for kycId: String) {
    invalidateTimer()
    manager.getSubmittedKycStatus(with: kycId) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        if model.state == .accepted {
          self.successfulWaiting.send()
        } else {
          self.resumeTimer(kycId: kycId)
        }
      case .failure:
        self.resumeTimer(kycId: kycId)
      }
    }
  }
  
}

private extension UserDocumentsModel {
  
  init(model: UserInfoModel) {
    self.documentCountry = model.countryOfResidence
  }
  
}
