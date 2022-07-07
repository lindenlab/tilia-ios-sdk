//
//  UserInfoViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import Combine
import Foundation

typealias UserInfoExpandSection = (index: Int, model: UserInfoModel, isExpanded: Bool, mode: UserInfoHeaderView.Mode, expandNext: Bool)
typealias UserInfoSetSectionText = (indexPath: IndexPath, fieldIndex: Int, text: String?, isFilled: Bool)
typealias UserInfoCoutryOfResidenceDidChange = (model: UserInfoModel, needToSetContactToDefault: Bool, wasUsResidence: Bool)

protocol UserInfoViewModelInputProtocol {
  func updateSection(_ section: UserInfoSectionBuilder.Section, at index: Int, isExpanded: Bool, nextSection: UserInfoSectionBuilder.Section?)
  func setText(_ text: String?, for section: UserInfoSectionBuilder.Section, indexPath: IndexPath, fieldIndex: Int)
  func upload()
  func complete()
}

protocol UserInfoViewModelOutputProtocol {
  var expandSection: PassthroughSubject<UserInfoExpandSection, Never> { get }
  var setSectionText: PassthroughSubject<UserInfoSetSectionText, Never> { get }
  var coutryOfResidenceDidChange: PassthroughSubject<UserInfoCoutryOfResidenceDidChange, Never> { get }
  var coutryOfResidenceDidSelect: PassthroughSubject<UserInfoModel, Never> { get }
  var uploading: CurrentValueSubject<Bool, Never> { get }
  var successfulUploading: PassthroughSubject<Void, Never> { get }
  var dismiss: PassthroughSubject<Void, Never> { get }
}

protocol UserInfoDataStore {
  var manager: NetworkManager { get }
  var selectedCountry: String { get }
  var onUserDocumentsComplete: (Bool) -> Void { get }
  var onUserDocumentsError: ((Error) -> Void)? { get }
}

protocol UserInfoViewModelProtocol: UserInfoViewModelInputProtocol, UserInfoViewModelOutputProtocol { }

final class UserInfoViewModel: UserInfoViewModelProtocol, UserInfoDataStore {
  
  let expandSection = PassthroughSubject<UserInfoExpandSection, Never>()
  let setSectionText = PassthroughSubject<UserInfoSetSectionText, Never>()
  let coutryOfResidenceDidChange = PassthroughSubject<UserInfoCoutryOfResidenceDidChange, Never>()
  let coutryOfResidenceDidSelect = PassthroughSubject<UserInfoModel, Never>()
  let uploading = CurrentValueSubject<Bool, Never>(false)
  let successfulUploading = PassthroughSubject<Void, Never>()
  let dismiss = PassthroughSubject<Void, Never>()
  
  let manager: NetworkManager
  var selectedCountry: String { return userInfoModel.countryOfResidence ?? "" }
  private(set) lazy var onUserDocumentsComplete: (Bool) -> Void = { [weak self] in
    guard let self = self else { return }
    if $0 {
      self.isUserDocumentsUploaded = true
      self.dismiss.send(())
    }
    self.onComplete?($0) // TODO: - Check here if we need to pass UserDocuments uploading state here
  }
  var onUserDocumentsError: ((Error) -> Void)? {
    return onError
  }
  
  private let onComplete: ((Bool) -> Void)?
  private let onError: ((Error) -> Void)?
  private var userInfoModel = UserInfoModel()
  private var isUserDocumentsUploaded = false
  
  init(manager: NetworkManager,
       onComplete: ((Bool) -> Void)?,
       onError: ((Error) -> Void)?) {
    self.manager = manager
    self.onComplete = onComplete
    self.onError = onError
  }
  
  func updateSection(_ section: UserInfoSectionBuilder.Section,
                     at index: Int,
                     isExpanded: Bool,
                     nextSection: UserInfoSectionBuilder.Section?) {
    let isSectionFilled = validator(for: section.type).isFilled(for: userInfoModel)
    let mode: UserInfoHeaderView.Mode = isSectionFilled ? .passed : .normal
    let expandNext = nextSection?.mode == .normal
    expandSection.send((index, userInfoModel, isExpanded, mode, expandNext))
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
      isFieldChanged = isFieldUpdated(&userInfoModel.countryOfResidence, with: text)
      if wasNil {
        coutryOfResidenceDidSelect.send(userInfoModel)
      } else if isFieldChanged {
        if wasUsResidence {
          userInfoModel.setTaxToDefault()
        }
        let needToSetAddressToDefault = wasUsResidence || userInfoModel.isUsResident
        if needToSetAddressToDefault {
          userInfoModel.setAddressToDefault()
        }
        coutryOfResidenceDidChange.send((userInfoModel, needToSetAddressToDefault, wasUsResidence))
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
      let date = DateFormatter.defaultFormatter.date(from: text ?? "")
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
      isFieldChanged = isFieldUpdated(&userInfoModel.address.region , with: text)
    case .postalCode:
      isFieldChanged = isFieldUpdated(&userInfoModel.address.postalCode, with: text)
    case .useAddressFor1099:
      let value = BoolModel(str: text ?? "")
      isFieldChanged = isFieldUpdated(&userInfoModel.canUseAddressFor1099, with: value)
    }
    
    if isFieldChanged {
      let isSectionFilled = validator(for: section.type).isFilled(for: userInfoModel)
      setSectionText.send((indexPath, fieldIndex, text, isSectionFilled))
    }
  }
  
  func upload() {
    // TODO: - Fix me
    uploading.send(true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.uploading.send(false)
      self.successfulUploading.send(())
    }
  }
  
  func complete() {
    onComplete?(isUserDocumentsUploaded)
  }
  
}

// MARK: - Private Methods

private extension UserInfoViewModel {
  
  func validator(for section: UserInfoSectionBuilder.Section.SectionType) -> UserInfoValidator {
    switch section {
    case .location: return UserInfoLocationValidator()
    case .personal: return UserInfoPersonalValidator()
    case .tax: return UserInfoTaxValidator()
    case .contact: return UserInfoContactValidator()
    }
  }
  
  func isFieldUpdated<Value: Equatable>(_ field: inout Value?, with value: Value?) -> Bool {
    guard field != value else { return false }
    field = value
    return true
  }
    
}
