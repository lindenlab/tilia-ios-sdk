//
//  UserInfoViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import Combine
import Foundation

typealias UserInfoExpandSection = (index: Int, model: UserInfoModel, isExpanded: Bool, isFilled: Bool, expandNext: Bool)
typealias UserInfoSetSectionText = (indexPath: IndexPath, fieldIndex: Int, text: String?, isFilled: Bool)
typealias UserInfoCoutryOfResidenceDidChange = (model: UserInfoModel, needToSetContactToDefault: Bool, wasUsResidence: Bool)

protocol UserInfoViewModelInputProtocol {
  func viewDidLoad()
  func updateSection(_ section: UserInfoSectionBuilder.Section, at index: Int, isExpanded: Bool, nextSection: UserInfoSectionBuilder.Section?)
  func setText(_ text: String?, for section: UserInfoSectionBuilder.Section, indexPath: IndexPath, fieldIndex: Int)
  func upload()
}

protocol UserInfoViewModelOutputProtocol {
  var contentLoading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
  var content: PassthroughSubject<Void, Never> { get }
  var expandSection: PassthroughSubject<UserInfoExpandSection, Never> { get }
  var setSectionText: PassthroughSubject<UserInfoSetSectionText, Never> { get }
  var coutryOfResidenceDidChange: PassthroughSubject<UserInfoCoutryOfResidenceDidChange, Never> { get }
  var coutryOfResidenceDidSelect: PassthroughSubject<UserInfoModel, Never> { get }
  var uploading: CurrentValueSubject<Bool, Never> { get }
  var uploadingDidSuccessfull: PassthroughSubject<Void, Never> { get }
}

protocol UserInfoDataStore {
  var manager: NetworkManager { get }
  var selectedCountry: String { get }
}

protocol UserInfoViewModelProtocol: UserInfoViewModelInputProtocol, UserInfoViewModelOutputProtocol { }

final class UserInfoViewModel: UserInfoViewModelProtocol, UserInfoDataStore {
  
  let contentLoading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<Error, Never>()
  let content = PassthroughSubject<Void, Never>()
  let expandSection = PassthroughSubject<UserInfoExpandSection, Never>()
  let setSectionText = PassthroughSubject<UserInfoSetSectionText, Never>()
  let coutryOfResidenceDidChange = PassthroughSubject<UserInfoCoutryOfResidenceDidChange, Never>()
  let coutryOfResidenceDidSelect = PassthroughSubject<UserInfoModel, Never>()
  let uploading = CurrentValueSubject<Bool, Never>(false)
  let uploadingDidSuccessfull = PassthroughSubject<Void, Never>()
  
  let manager: NetworkManager
  var selectedCountry: String { return userInfoModel.countryOfResidence ?? "" }
  private var userInfoModel = UserInfoModel()
  
  
  init(manager: NetworkManager) {
    self.manager = manager
  }
  
  func viewDidLoad() {
    // TODO: - Fix me
    contentLoading.send(true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.contentLoading.send(false)
      self.content.send(())
    }
  }
  
  func updateSection(_ section: UserInfoSectionBuilder.Section,
                     at index: Int,
                     isExpanded: Bool,
                     nextSection: UserInfoSectionBuilder.Section?) {
    let isSectionFilled = validator(for: section.type).isFilled(for: userInfoModel)
    let expandNext = nextSection?.mode == .normal
    expandSection.send((index, userInfoModel, isExpanded, isSectionFilled, expandNext))
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
      self.uploadingDidSuccessfull.send(())
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
