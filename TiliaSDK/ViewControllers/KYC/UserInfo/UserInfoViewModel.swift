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
  func complete()
}

protocol UserInfoViewModelOutputProtocol {
  var expandSection: PassthroughSubject<UserInfoExpandSection, Never> { get }
  var setSectionText: PassthroughSubject<UserInfoSetSectionText, Never> { get }
  var coutryOfResidenceDidChange: PassthroughSubject<UserInfoCoutryOfResidenceDidChange, Never> { get }
  var coutryOfResidenceDidSelect: PassthroughSubject<UserInfoModel, Never> { get }
  var dismiss: PassthroughSubject<Void, Never> { get }
}

protocol UserInfoDataStore {
  var manager: NetworkManager { get }
  var userInfoModel: UserInfoModel { get }
  var onUserDocumentsComplete: (Bool) -> Void { get }
  var onUserDocumentsError: ((Error) -> Void)? { get }
}

protocol UserInfoViewModelProtocol: UserInfoViewModelInputProtocol, UserInfoViewModelOutputProtocol { }

final class UserInfoViewModel: UserInfoViewModelProtocol, UserInfoDataStore {
  
  let expandSection = PassthroughSubject<UserInfoExpandSection, Never>()
  let setSectionText = PassthroughSubject<UserInfoSetSectionText, Never>()
  let coutryOfResidenceDidChange = PassthroughSubject<UserInfoCoutryOfResidenceDidChange, Never>()
  let coutryOfResidenceDidSelect = PassthroughSubject<UserInfoModel, Never>()
  let dismiss = PassthroughSubject<Void, Never>()
  
  let manager: NetworkManager
  private(set) var userInfoModel = UserInfoModel()
  private(set) lazy var onUserDocumentsComplete: (Bool) -> Void = { [weak self] in
    guard let self = self else { return }
    if $0 {
      self.isUserDocumentsUploaded = true
      self.dismiss.send()
    }
    self.onComplete?($0) // TODO: - Check here if we need to pass UserDocuments uploading state here
  }
  var onUserDocumentsError: ((Error) -> Void)? {
    return onError
  }
  
  private let onComplete: ((Bool) -> Void)?
  private let onError: ((Error) -> Void)?
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
                     nextSectionIndex: Int?) {
    let isSectionFilled = validator(for: section.type).isFilled(for: userInfoModel)
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
      if wasNil {
        isFieldChanged = true
        userInfoModel.countryOfResidence = CountryModel.countries.first { $0.name == text }
        if userInfoModel.isUsResident {
          userInfoModel.tax = .init()
        }
        coutryOfResidenceDidSelect.send(userInfoModel)
      } else if userInfoModel.countryOfResidence?.name != text {
        let wasUsResidence = userInfoModel.isUsResident
        isFieldChanged = true
        userInfoModel.countryOfResidence = CountryModel.countries.first { $0.name == text }
        if wasUsResidence {
          userInfoModel.tax = nil
        } else if userInfoModel.isUsResident {
          userInfoModel.tax = .init()
        }
        userInfoModel.setAddressToDefault()
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
      let date = DateFormatter.defaultFormatter.date(from: text ?? "")
      isFieldChanged = isFieldUpdated(&userInfoModel.dateOfBirth, with: date)
    case .ssn:
      if userInfoModel.tax?.ssn != text {
        isFieldChanged = true
        userInfoModel.tax?.ssn = text
      }
    case .signature:
      if userInfoModel.tax?.signature != text {
        isFieldChanged = true
        userInfoModel.tax?.signature = text
      }
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
    
    if isFieldChanged {
      let isSectionFilled = validator(for: section.type).isFilled(for: userInfoModel)
      setSectionText.send((indexPath, fieldIndex, text, isSectionFilled))
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
