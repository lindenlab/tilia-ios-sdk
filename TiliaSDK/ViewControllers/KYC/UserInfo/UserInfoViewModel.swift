//
//  UserInfoViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import Combine
import Foundation

typealias UserInfoExpandSection = (index: Int, model: UserInfoModel, isExpanded: Bool, isFilled: Bool)
typealias UserInfoSetSectionText = (indexPath: IndexPath, fieldIndex: Int, text: String?, isFilled: Bool)

protocol UserInfoViewModelInputProtocol {
  func viewDidLoad()
  func updateSection(at index: Int, sectionType: UserInfoSectionBuilder.Section.SectionType, isExpanded: Bool)
  func setText(_ text: String?, for section: UserInfoSectionBuilder.Section, indexPath: IndexPath, fieldIndex: Int)
}

protocol UserInfoViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
  var content: PassthroughSubject<Void, Never> { get }
  var expandSection: PassthroughSubject<UserInfoExpandSection, Never> { get }
  var setSectionText: PassthroughSubject<UserInfoSetSectionText, Never> { get }
  var coutryOfResidenceDidChange: PassthroughSubject<UserInfoModel, Never> { get }
  var coutryOfResidenceDidSelect: PassthroughSubject<UserInfoModel, Never> { get }
}

protocol UserInfoDataStore {
  var manager: NetworkManager { get }
}

protocol UserInfoViewModelProtocol: UserInfoViewModelInputProtocol, UserInfoViewModelOutputProtocol { }

final class UserInfoViewModel: UserInfoViewModelProtocol, UserInfoDataStore {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<Error, Never>()
  let content = PassthroughSubject<Void, Never>()
  let expandSection = PassthroughSubject<UserInfoExpandSection, Never>()
  let setSectionText = PassthroughSubject<UserInfoSetSectionText, Never>()
  let coutryOfResidenceDidChange = PassthroughSubject<UserInfoModel, Never>()
  let coutryOfResidenceDidSelect = PassthroughSubject<UserInfoModel, Never>()
  
  let manager: NetworkManager
  private var userInfoModel = UserInfoModel()
  
  
  init(manager: NetworkManager) {
    self.manager = manager
  }
  
  func viewDidLoad() {
    content.send(())// TODO: - Fix this
  }
  
  func updateSection(at index: Int,
                     sectionType: UserInfoSectionBuilder.Section.SectionType,
                     isExpanded: Bool) {
    let isSectionFilled = validator(for: sectionType).isFilled(for: userInfoModel)
    expandSection.send((index, userInfoModel, isExpanded, isSectionFilled))
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
      isFieldChanged = isFieldUpdated(&userInfoModel.countryOfResidence, with: text)
      if wasNil {
        coutryOfResidenceDidSelect.send(userInfoModel)
      } else if isFieldChanged {
        userInfoModel.setAddressToDefault()
        coutryOfResidenceDidChange.send(userInfoModel)
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
