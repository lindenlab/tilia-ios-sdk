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
  func load()
  func updateSection(_ section: UserInfoSectionBuilder.Section, at index: Int, isExpanded: Bool, nextSectionIndex: Int?)
  func setText(_ text: String?, for section: UserInfoSectionBuilder.Section, indexPath: IndexPath, fieldIndex: Int)
  func onNext(for section: UserInfoSectionBuilder.Section, at index: Int)
  func editEmail()
  func cancelEditEmail()
  func updateEmail()
  func upload()
  func complete(isFromCloseAction: Bool)
}

protocol UserInfoViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var content: PassthroughSubject<UserInfoModel, Never> { get }
  var error: PassthroughSubject<ErrorWithBoolModel, Never> { get }
  var expandSection: PassthroughSubject<UserInfoExpandSection, Never> { get }
  var setSectionText: PassthroughSubject<UserInfoSetSectionText, Never> { get }
  var coutryOfResidenceDidChange: PassthroughSubject<UserInfoCoutryOfResidenceDidChange, Never> { get }
  var coutryOfResidenceDidSelect: PassthroughSubject<Void, Never> { get }
  var nextSection: PassthroughSubject<Int, Never> { get }
  var uploading: CurrentValueSubject<Bool, Never> { get }
  var uploadDocuments: PassthroughSubject<Void, Never> { get }
  var successfulUploading: PassthroughSubject<Void, Never> { get }
  var processing: PassthroughSubject<Void, Never> { get }
  var manualReview: PassthroughSubject<Void, Never> { get }
  var failedCompleting: PassthroughSubject<Void, Never> { get }
  var successfulCompleting: PassthroughSubject<Void, Never> { get }
  var verifyEmail: PassthroughSubject<Void, Never> { get }
  var emailVerified: PassthroughSubject<String, Never> { get }
}

protocol UserInfoDataStore {
  var manager: NetworkManager { get }
  var userInfoModel: UserInfoModel { get }
  var userEmail: String { get }
  var verifyEmailMode: VerifyEmailMode { get }
  var onUpdate: ((TLUpdateCallback) -> Void)? { get }
  var onUserDocumentsComplete: (SubmittedKycModel) -> Void { get }
  var onEmailVerified: (VerifyEmailMode) -> Void { get }
  var onError: ((TLErrorCallback) -> Void)? { get }
}

protocol UserInfoViewModelProtocol: UserInfoViewModelInputProtocol, UserInfoViewModelOutputProtocol { }

final class UserInfoViewModel: UserInfoViewModelProtocol, UserInfoDataStore {
  
  let loading = PassthroughSubject<Bool, Never>()
  let content = PassthroughSubject<UserInfoModel, Never>()
  let error = PassthroughSubject<ErrorWithBoolModel, Never>()
  let expandSection = PassthroughSubject<UserInfoExpandSection, Never>()
  let setSectionText = PassthroughSubject<UserInfoSetSectionText, Never>()
  let coutryOfResidenceDidChange = PassthroughSubject<UserInfoCoutryOfResidenceDidChange, Never>()
  let coutryOfResidenceDidSelect = PassthroughSubject<Void, Never>()
  let nextSection = PassthroughSubject<Int, Never>()
  let uploading = CurrentValueSubject<Bool, Never>(false)
  let uploadDocuments = PassthroughSubject<Void, Never>()
  let successfulUploading = PassthroughSubject<Void, Never>()
  let processing = PassthroughSubject<Void, Never>()
  let manualReview = PassthroughSubject<Void, Never>()
  let failedCompleting = PassthroughSubject<Void, Never>()
  let successfulCompleting = PassthroughSubject<Void, Never>()
  let verifyEmail = PassthroughSubject<Void, Never>()
  let emailVerified = PassthroughSubject<String, Never>()
  
  let manager: NetworkManager
  private(set) var userInfoModel = UserInfoModel()
  var userEmail: String { return userInfoModel.needToVerifyEmail ?? "" }
  var verifyEmailMode: VerifyEmailMode { return userInfoModel.isEmailVerified ? .update : .verify }
  let onUpdate: ((TLUpdateCallback) -> Void)?
  private(set) lazy var onUserDocumentsComplete: (SubmittedKycModel) -> Void = { [weak self] in
    self?.getStatus(for: $0)
  }
  private(set) lazy var onEmailVerified: (VerifyEmailMode) -> Void = { [weak self] in
    self?.didVerifyEmail(with: $0)
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
  
  func load() {
    loading.send(true)
    manager.getUserInfo { [weak self] result in
      guard let self = self else { return }
      self.loading.send(false)
      switch result {
      case .success(let model):
        self.userInfoModel.email = model.email
        self.content.send(self.userInfoModel)
      case .failure(let error):
        self.didFail(with: .init(error: error, value: true))
      }
    }
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
    case .email:
      isFieldChanged = isFieldUpdated(&userInfoModel.email, with: text)
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
    case .useAddressForTax:
      let value = BoolModel(str: text ?? "")
      isFieldChanged = isFieldUpdated(&userInfoModel.address.canUseAddressForTax, with: value)
    }
    
    guard isFieldChanged,
          let isSectionFilled = validator(for: section.type)?.isFilled(for: userInfoModel) else { return }
    setSectionText.send((indexPath, fieldIndex, text, isSectionFilled))
  }
  
  func onNext(for section: UserInfoSectionBuilder.Section, at index: Int) {
    switch section.type {
    case .email:
      verifyEmail.send()
    default:
      nextSection.send(index)
    }
  }
  
  func editEmail() {
    
  }
  
  func cancelEditEmail() {
    
  }
  
  func updateEmail() {
    
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
          self.didFail(with: .init(error: error, value: false))
        }
      }
    }
  }
  
  func complete(isFromCloseAction: Bool) {
    let event = TLEvent(flow: .kyc,
                        action: isFromCloseAction ? .closedByUser : isFlowCompleted ? .completed : .cancelledByUser)
    let model = TLCompleteCallback(event: event,
                                   state: isFromCloseAction ? .error : isFlowCompleted ? .completed : .cancelled)
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
    case .email: return UserInfoEmailValidator()
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
        self.didFail(with: .init(error: error, value: false))
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
  
  func didFail(with error: ErrorWithBoolModel) {
    self.error.send(error)
    let event = TLEvent(flow: .kyc, action: .error)
    let model = TLErrorCallback(event: event,
                                error: L.errorKycTitle,
                                message: error.error.localizedDescription)
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
  
  func didVerifyEmail(with mode: VerifyEmailMode) {
    let event = TLEvent(flow: .kyc, action: .emailVerified)
    let message = mode.successTitle
    let model = TLUpdateCallback(event: event, message: message)
    onUpdate?(model)
    if userInfoModel.email != nil {
      userInfoModel.isEmailUpdated = true
    }
    userInfoModel.email = userInfoModel.needToVerifyEmail
    // TODO: - Here we need to reload cell after successful verify
    userInfoModel.needToVerifyEmail = nil
    emailVerified.send(message)
  }
  
}
