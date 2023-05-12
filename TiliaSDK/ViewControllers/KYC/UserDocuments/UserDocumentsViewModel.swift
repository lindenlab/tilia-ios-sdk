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
typealias UserDocumentsSetDocumentImage = (index: Int, image: UIImage)
typealias UserDocumentsAddAdditionalDocuments = (index: Int, documentImages: [UIImage])
typealias UserDocumentsDeleteAdditionalDocument = (itemIndex: Int, documentIndex: Int)

protocol UserDocumentsViewModelInputProtocol {
  func load()
  func setText(_ text: String?, for item: UserDocumentsSectionBuilder.Section.Item, at index: Int)
  func setImage(_ image: UIImage?, for item: UserDocumentsSectionBuilder.Section.Item, at index: Int, with url: URL?)
  func setFiles(with urls: [URL], at index: Int)
  func deleteDocument(forItemIndex itemIndex: Int, atDocumentIndex documentIndex: Int)
  func upload()
  func complete()
}

protocol UserDocumentsViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<ErrorWithBoolModel, Never> { get }
  var setText: PassthroughSubject<UserDocumentsSetText, Never> { get }
  var setDocumentImage: PassthroughSubject<UserDocumentsSetDocumentImage, Never> { get }
  var documentDidSelect: PassthroughSubject<UserDocumentsModel, Never> { get }
  var documentDidChange: PassthroughSubject<UserDocumentsModel.Document, Never> { get }
  var shouldAddAdditionalDocuments: PassthroughSubject<Bool, Never> { get }
  var addAdditionalDocuments: PassthroughSubject<UserDocumentsAddAdditionalDocuments, Never> { get }
  var deleteAdditionalDocument: PassthroughSubject<UserDocumentsDeleteAdditionalDocument, Never> { get }
  var chooseFileDidFail: PassthroughSubject<String, Never> { get }
  var fillingContent: PassthroughSubject<Bool, Never> { get }
  var uploading: CurrentValueSubject<Bool, Never> { get }
  var dismiss: PassthroughSubject<Void, Never> { get }
}

protocol UserDocumentsViewModelProtocol: UserDocumentsViewModelInputProtocol, UserDocumentsViewModelOutputProtocol { }

final class UserDocumentsViewModel: UserDocumentsViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<ErrorWithBoolModel, Never>()
  let setText = PassthroughSubject<UserDocumentsSetText, Never>()
  let setDocumentImage = PassthroughSubject<UserDocumentsSetDocumentImage, Never>()
  let documentDidSelect = PassthroughSubject<UserDocumentsModel, Never>()
  let documentDidChange = PassthroughSubject<UserDocumentsModel.Document, Never>()
  let shouldAddAdditionalDocuments = PassthroughSubject<Bool, Never>()
  let addAdditionalDocuments = PassthroughSubject<UserDocumentsAddAdditionalDocuments, Never>()
  let deleteAdditionalDocument = PassthroughSubject<UserDocumentsDeleteAdditionalDocument, Never>()
  let chooseFileDidFail = PassthroughSubject<String, Never>()
  let fillingContent = PassthroughSubject<Bool, Never>()
  let uploading = CurrentValueSubject<Bool, Never>(false)
  let dismiss = PassthroughSubject<Void, Never>()
  
  private let manager: NetworkManager
  private let userInfoModel: UserInfoModel
  private var userDocumentsModel: UserDocumentsModel
  private let onComplete: ((SubmittedKycModel) -> Void)
  private let onError: ((TLErrorCallback) -> Void)?
  private let processQueue = DispatchQueue(label: "io.tilia.ios.sdk.userDocumentsProcessQueue", attributes: .concurrent)
  private var submittedKyc: SubmittedKycModel?
  private var countryCodesNotRequiringAddressDocuments: [String] = [] {
    didSet {
      guard
        let defaultSelectedCountry = userDocumentsModel.documentCountry,
        !countryCodesNotRequiringAddressDocuments.contains(where: { $0 == defaultSelectedCountry.code }) else { return }
      userDocumentsModel.additionalDocuments = []
    }
  }
  
  init(manager: NetworkManager,
       userInfoModel: UserInfoModel,
       onComplete: @escaping (SubmittedKycModel) -> Void,
       onError: ((TLErrorCallback) -> Void)?) {
    self.manager = manager
    self.userInfoModel = userInfoModel
    self.userDocumentsModel = UserDocumentsModel(model: userInfoModel)
    self.onComplete = onComplete
    self.onError = onError
  }
  
  func load() {
    loading.send(true)
    manager.getSettings { [weak self] result in
      guard let self = self else { return }
      self.loading.send(false)
      switch result {
      case .success(let model):
        self.countryCodesNotRequiringAddressDocuments = model.kyc.countriesNotRequiringAddressDocuments
      case .failure(let error):
        self.didFail(with: .init(error: error, value: true))
      }
    }
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
    case .documentCountry where userDocumentsModel.documentCountry?.name != text:
      isFieldChanged = true
      let country = CountryModel.countries.first { $0.name == text }
      userDocumentsModel.documentCountry = country
      let wereNilAdditionalDocuments = userDocumentsModel.additionalDocuments == nil
      let additionalDocumentsNotRequired = countryCodesNotRequiringAddressDocuments.contains(where: { $0 == country?.code })
      if additionalDocumentsNotRequired {
        if !wereNilAdditionalDocuments {
          userDocumentsModel.additionalDocuments = nil
          shouldAddAdditionalDocuments.send(false)
        }
      } else if wereNilAdditionalDocuments {
        userDocumentsModel.additionalDocuments = []
        shouldAddAdditionalDocuments.send(true)
      }
    default:
      break
    }
    
    if isFieldChanged {
      setText.send((index, text))
      updateFillingSectionObserver()
    }
  }
  
  func setImage(_ image: UIImage?, for item: UserDocumentsSectionBuilder.Section.Item, at index: Int, with url: URL?) {
    guard let image = image else { return }
    resizeImage(image) { (resizedImage, compressedImage) in
      guard let compressedImage = compressedImage else {
        self.chooseFileDidFail.send(L.failedToSelectBigImage)
        return
      }
      
      let documentImage = UserDocumentsModel.DocumentImage(image: resizedImage,
                                                           data: compressedImage,
                                                           type: .image)
      switch item.mode {
      case let .photo(model):
        switch model.type {
        case .frontSide:
          self.userDocumentsModel.frontImage = documentImage
        case .backSide:
          self.userDocumentsModel.backImage = documentImage
        }
        self.setDocumentImage.send((index, resizedImage))
      case .additionalDocuments:
        let initialDocumentsSize = self.getDocumentsSize(self.userDocumentsModel.additionalDocuments ?? [])
        if initialDocumentsSize + compressedImage.count > C.maxAdditionalDocumentsSize {
          self.chooseFileDidFail.send(L.failedToSelectReachedMaxSize)
        } else {
          self.userDocumentsModel.additionalDocuments?.append(documentImage)
          self.addAdditionalDocuments.send((index, [resizedImage]))
        }
      default:
        break
      }
      self.updateFillingSectionObserver()
    }
    url.map { deleteTempFile(at: $0) }
  }
  
  func setFiles(with urls: [URL], at index: Int) {
    let initialDocumentsSize = getDocumentsSize(userDocumentsModel.additionalDocuments ?? [])
    processFiles(with: urls, initialDocumentsSize: initialDocumentsSize) { documents, error in
      if !documents.isEmpty {
        self.userDocumentsModel.additionalDocuments?.append(contentsOf: documents)
        self.addAdditionalDocuments.send((index, documents.map { $0.image }))
        self.updateFillingSectionObserver()
      }
      error.map { self.chooseFileDidFail.send($0) }
      urls.forEach { self.deleteTempFile(at: $0) }
    }
  }
  
  func deleteDocument(forItemIndex itemIndex: Int, atDocumentIndex documentIndex: Int) {
    userDocumentsModel.additionalDocuments?.remove(at: documentIndex)
    deleteAdditionalDocument.send((itemIndex, documentIndex))
    updateFillingSectionObserver()
  }
  
  func upload() {
    uploading.send(true)
    submit { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        self.submittedKyc = model
        self.dismiss.send()
      case .failure(let error):
        self.uploading.send(false)
        self.didFail(with: .init(error: error, value: false))
      }
    }
  }
  
  func complete() {
    submittedKyc.map { onComplete($0) }
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsViewModel {
  
  func isFieldUpdated<Value: Equatable>(_ field: inout Value, with value: Value) -> Bool {
    guard field != value else { return false }
    field = value
    return true
  }
  
  func image(from document: PDFDocument) -> UIImage? {
    guard let page = document.page(at: 0) else { return nil }
    let pageRect = page.bounds(for: .mediaBox)
    return page.thumbnail(of: pageRect.size, for: .mediaBox)
  }
  
  func resizeImage(_ image: UIImage, completion: @escaping (UIImage, Data?) -> Void) {
    processQueue.async {
      let imageCompressor = ImageCompressor()
      let resizedImage = imageCompressor.resized(image: image)
      let compressedImage = imageCompressor.compressed(image: image, withMaxSize: C.maxImageSize)
      DispatchQueue.main.async { completion(resizedImage, compressedImage) }
    }
  }
  
  func processFiles(with urls: [URL], initialDocumentsSize: Int, completion: @escaping ([UserDocumentsModel.DocumentImage], String?) -> Void) {
    processQueue.async {
      var errors: Set<String> = []
      var documents: [UserDocumentsModel.DocumentImage] = []
      for url in urls {
        guard
          let document = PDFDocument(url: url),
          document.pageCount != 0 else { continue }
        if document.isLocked {
          errors.insert(L.failedToSelectHasPassword)
        } else if initialDocumentsSize + self.getDocumentsSize(documents) + self.getFileSize(at: url) > C.maxAdditionalDocumentsSize {
          errors.insert(L.failedToSelectReachedMaxSize)
        } else if let data = try? Data(contentsOf: url), let image = self.image(from: document) {
          let resizedImage = ImageCompressor().resized(image: image)
          documents.append(.init(image: resizedImage,
                                 data: data,
                                 type: .pdf))
        }
      }
      let error = errors.isEmpty ? nil : errors.joined(separator: "\n")
      DispatchQueue.main.async { completion(documents, error) }
    }
  }
  
  func submit(completion: @escaping CompletionResultHandler<SubmittedKycModel>) {
    processQueue.async {
      let submitModel = SubmitKycModel(userInfoModel: self.userInfoModel,
                                       userDocumentsModel: self.userDocumentsModel)
      self.manager.submitKyc(with: submitModel, completion: completion)
    }
  }
  
  func updateFillingSectionObserver() {
    let isSectionFilled = UserDocumentsValidator.isFilled(for: userDocumentsModel)
    fillingContent.send(isSectionFilled)
  }
  
  func getDocumentsSize(_ documents: [UserDocumentsModel.DocumentImage]) -> Int {
    return documents.reduce(0) { result, document in
      return result + document.data.count
    }
  }
  
  func getFileSize(at url: URL) -> Int {
    return (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
  }
  
  func deleteTempFile(at url: URL) {
    processQueue.async {
      try? FileManager.default.removeItem(at: url)
    }
  }
  
  func didFail(with error: ErrorWithBoolModel) {
    self.error.send(error)
    let event = TLEvent(flow: .kyc, action: .error)
    let model = TLErrorCallback(event: event,
                                error: L.errorKycTitle,
                                message: error.error.localizedDescription)
    self.onError?(model)
  }
  
}

private extension UserDocumentsViewModel {
  
  struct C {
    static let maxImageSize = 1024 * 1024 * 3
    static let maxAdditionalDocumentsSize = 1024 * 1024 * 20
  }
  
  struct ImageCompressor {
    
    private static let minimumCompressionQuality: CGFloat = 0.1
    private static let compressionQualityStep: CGFloat = 0.1
    private static let maxSizeToDisplay = CGSize(width: 512, height: 512)
    
    func compressed(image: UIImage, withMaxSize maxSize: Int) -> Data? {
      
      func compressed(image: UIImage, compressionQuality: CGFloat) -> Data? {
        guard
          compressionQuality >= Self.minimumCompressionQuality,
          let data = image.jpegData(compressionQuality: compressionQuality) else { return nil }
        if data.count <= maxSize {
          return data
        } else {
          let newCompressionQuality = compressionQuality - ImageCompressor.compressionQualityStep
          return compressed(image: image, compressionQuality: newCompressionQuality)
        }
      }
      
      return compressed(image: image, compressionQuality: 1)
    }
    
    func resized(image: UIImage) -> UIImage {
      let maxSizeToDisplay = Self.maxSizeToDisplay
      var imageSize = image.size
      
      guard imageSize.width > maxSizeToDisplay.width || imageSize.height > maxSizeToDisplay.height else { return image }
      let ratio = max(imageSize.width / maxSizeToDisplay.width, imageSize.height / maxSizeToDisplay.height)
      imageSize.width = imageSize.width / ratio
      imageSize.height = imageSize.height / ratio
      let renderer = UIGraphicsImageRenderer(size: imageSize)
      return renderer.image { _ in
        image.draw(in: .init(origin: .zero, size: imageSize))
      }
    }
    
  }
  
}

private extension UserDocumentsModel {
  
  init(model: UserInfoModel) {
    self.documentCountry = model.countryOfResidence
  }
  
}
