//
//  UserInfoViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import Combine
import Foundation

typealias UserInfoExpandSection = (index: Int, model: UserInfoModel, isExpanded: Bool, isFilled: Bool, nextIndex: Int?)
typealias UserInfoSetSectionText = (indexPath: IndexPath, fieldIndex: Int, text: String?, isFilled: Bool)
typealias UserInfoCoutryOfResidenceDidChange = (model: UserInfoModel, wasUsResidence: Bool)

protocol UserInfoViewModelInputProtocol {
  func updateSection(_ section: UserInfoSectionBuilder.Section, at index: Int, isExpanded: Bool, nextSectionIndex: Int?)
  func setText(_ text: String?, for section: UserInfoSectionBuilder.Section, indexPath: IndexPath, fieldIndex: Int)
  func upload()
  func complete()
}

protocol UserInfoViewModelOutputProtocol {
  var error: PassthroughSubject<Error, Never> { get }
  var expandSection: PassthroughSubject<UserInfoExpandSection, Never> { get }
  var setSectionText: PassthroughSubject<UserInfoSetSectionText, Never> { get }
  var coutryOfResidenceDidChange: PassthroughSubject<UserInfoCoutryOfResidenceDidChange, Never> { get }
  var coutryOfResidenceDidSelect: PassthroughSubject<Void, Never> { get }
  var uploading: CurrentValueSubject<Bool, Never> { get }
  var uploadDocuments: PassthroughSubject<Void, Never> { get }
  var successfulUploading: PassthroughSubject<Void, Never> { get }
  var processing: PassthroughSubject<Void, Never> { get }
  var manualReview: PassthroughSubject<Void, Never> { get }
  var failedCompleting: PassthroughSubject<Void, Never> { get }
  var successfulCompleting: PassthroughSubject<Void, Never> { get }
}

protocol UserInfoDataStore {
  var manager: NetworkManager { get }
  var userInfoModel: UserInfoModel { get }
  var onUpdate: ((TLUpdateCallback) -> Void)? { get }
  var onUserDocumentsComplete: (SubmittedKycModel) -> Void { get }
  var onError: ((TLErrorCallback) -> Void)? { get }
}

protocol UserInfoViewModelProtocol: UserInfoViewModelInputProtocol, UserInfoViewModelOutputProtocol { }

final class UserInfoViewModel: UserInfoViewModelProtocol, UserInfoDataStore {
  
  let error = PassthroughSubject<Error, Never>()
  let expandSection = PassthroughSubject<UserInfoExpandSection, Never>()
  let setSectionText = PassthroughSubject<UserInfoSetSectionText, Never>()
  let coutryOfResidenceDidChange = PassthroughSubject<UserInfoCoutryOfResidenceDidChange, Never>()
  let coutryOfResidenceDidSelect = PassthroughSubject<Void, Never>()
  let uploading = CurrentValueSubject<Bool, Never>(false)
  let uploadDocuments = PassthroughSubject<Void, Never>()
  let successfulUploading = PassthroughSubject<Void, Never>()
  let processing = PassthroughSubject<Void, Never>()
  let manualReview = PassthroughSubject<Void, Never>()
  let failedCompleting = PassthroughSubject<Void, Never>()
  let successfulCompleting = PassthroughSubject<Void, Never>()
  
  let manager: NetworkManager
  private(set) var userInfoModel = UserInfoModel()
  let onUpdate: ((TLUpdateCallback) -> Void)?
  private(set) lazy var onUserDocumentsComplete: (SubmittedKycModel) -> Void = { [weak self] in
    self?.getStatus(for: $0)
  }
  let onError: ((TLErrorCallback) -> Void)?
  
  private let onComplete: ((TLCompleteCallback) -> Void)?
  private var isFlowCompleted = false
  private var timer: Timer?
  
  init(manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    self.manager = manager
    self.onUpdate = onUpdate
    self.onComplete = onComplete
    self.onError = onError
  }
  
  func updateSection(_ section: UserInfoSectionBuilder.Section,
                     at index: Int,
                     isExpanded: Bool,
                     nextSectionIndex: Int?) {
    guard let isSectionFilled = validator(for: section.type)?.isFilled(for: userInfoModel) else { return }
    expandSection.send((index, userInfoModel, isExpanded, isSectionFilled, nextSectionIndex))
  }
  
  func setText(_ text: String?,
               for section: UserInfoSectionBuilder.Section,
               indexPath: IndexPath,
               fieldIndex: Int) {
    guard case let .fields(field) = section.items[indexPath.row].mode else { return }
    
    var isFieldChanged = false
    
    switch field.type {
    case .countryOfResidance:
      let wasNil = userInfoModel.countryOfResidence == nil
      let wasUsResidence = userInfoModel.isUsResident
      let foundCountry = CountryModel.countries.first { $0.name == text }
      isFieldChanged = isFieldUpdated(&userInfoModel.countryOfResidence, with: foundCountry)
      if wasNil {
        coutryOfResidenceDidSelect.send()
      } else if isFieldChanged {
        userInfoModel.setAddressToDefault()
        if wasUsResidence || userInfoModel.isUsResident {
          userInfoModel.setTaxToDefault()
        }
        coutryOfResidenceDidChange.send((userInfoModel, wasUsResidence))
      }
    case .fullName:
      switch fieldIndex {
      case 0:
        isFieldChanged = isFieldUpdated(&userInfoModel.fullName.first, with: text)
      case 1:
        isFieldChanged = isFieldUpdated(&userInfoModel.fullName.middle, with: text)
      case 2:
        isFieldChanged = isFieldUpdated(&userInfoModel.fullName.last, with: text)
      default: break
      }
    case .dateOfBirth:
      let date = DateFormatter.longDateFormatter.date(from: text ?? "")
      isFieldChanged = isFieldUpdated(&userInfoModel.dateOfBirth, with: date)
    case .ssn:
      isFieldChanged = isFieldUpdated(&userInfoModel.tax.ssn, with: text)
    case .signature:
      isFieldChanged = isFieldUpdated(&userInfoModel.tax.signature, with: text)
    case .address:
      switch fieldIndex {
      case 0:
        isFieldChanged = isFieldUpdated(&userInfoModel.address.street, with: text)
      case 1:
        isFieldChanged = isFieldUpdated(&userInfoModel.address.apartment, with: text)
      default: break
      }
    case .city:
      isFieldChanged = isFieldUpdated(&userInfoModel.address.city, with: text)
    case .state:
      if userInfoModel.address.region.name != text {
        isFieldChanged = true
        if let states = userInfoModel.countryOfResidence?.states, let state = states.first(where: { $0.name == text }) {
          userInfoModel.address.region = state
        } else {
          userInfoModel.address.region.name = text
        }
      }
    case .postalCode:
      isFieldChanged = isFieldUpdated(&userInfoModel.address.postalCode, with: text)
    case .useAddressFor1099:
      let value = BoolModel(str: text ?? "")
      isFieldChanged = isFieldUpdated(&userInfoModel.canUseAddressFor1099, with: value)
    }
    
    guard isFieldChanged,
          let isSectionFilled = validator(for: section.type)?.isFilled(for: userInfoModel) else { return }
    setSectionText.send((indexPath, fieldIndex, text, isSectionFilled))
  }
  
  func upload() {
    if userInfoModel.needDocuments {
      uploadDocuments.send()
    } else {
      uploading.send(true)
      let submitModel = SubmitKycModel(userInfoModel: userInfoModel, userDocumentsModel: nil)
      manager.submitKyc(with: submitModel) { [weak self] result in
        guard let self = self else { return }
        self.uploading.send(false)
        switch result {
        case .success(let model):
          self.getStatus(for: model)
        case .failure(let error):
          self.didFail(with: error)
        }
      }
    }
  }
  
  func complete() {
    let event = TLEvent(flow: .kyc,
                        action: isFlowCompleted ? .completed : .cancelledByUser)
    let model = TLCompleteCallback(event: event,
                                   state: isFlowCompleted ? .completed : .cancelled)
    onComplete?(model)
  }
  
  deinit {
    timer?.invalidate()
  }
  
}

// MARK: - Private Methods

private extension UserInfoViewModel {
  
  func validator(for section: UserInfoSectionBuilder.Section.SectionType) -> UserInfoValidator? {
    switch section {
    case .location: return UserInfoLocationValidator()
    case .personal: return UserInfoPersonalValidator()
    case .tax: return UserInfoTaxValidator()
    case .contact: return UserInfoContactValidator()
    default: return nil
    }
  }
  
  func isFieldUpdated<Value: Equatable>(_ field: inout Value?, with value: Value?) -> Bool {
    guard field != value else { return false }
    field = value
    return true
  }
  
  func getSubmittedStatus(for kycId: String) {
    invalidateTimer()
    manager.getSubmittedKycStatus(with: kycId) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let model):
        self.sendUpdateCallback(with: model.state)
        switch model.state {
        case .accepted:
          self.isFlowCompleted = true
          self.successfulCompleting.send()
        case .processing:
          self.resumeTimer(kycId: kycId)
          self.processing.send()
        case .manualReview:
          self.manualReview.send()
        case .denied, .reverify, .noData:
          self.failedCompleting.send()
        }
      case .failure(let error):
        self.didFail(with: error)
      }
    }
  }
  
  func resumeTimer(kycId: String) {
    timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
      guard let self = self else { return }
      self.getSubmittedStatus(for: kycId)
    }
  }

  func invalidateTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  func didFail(with error: Error) {
    self.error.send(error)
    let event = TLEvent(flow: .kyc, action: .error)
    let model = TLErrorCallback(event: event,
                                error: L.errorKycTitle,
                                message: error.localizedDescription)
    onError?(model)
  }

  func sendUpdateCallback(with state: SubmittedKycStateModel) {
    let event = TLEvent(flow: .kyc, action: .kycInfoSubmitted)
    let model = TLUpdateCallback(event: event,
                                 message: L.kycInfoSubmitted(with: state.rawValue))
    onUpdate?(model)
  }
  
  func getStatus(for model: SubmittedKycModel) {
    successfulUploading.send()
    sendUpdateCallback(with: model.state)
    resumeTimer(kycId: model.kycId)
  }
  
}
