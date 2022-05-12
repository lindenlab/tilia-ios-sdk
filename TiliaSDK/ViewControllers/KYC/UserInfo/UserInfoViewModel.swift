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
  var coutryOfResidenceDidChange: PassthroughSubject<String?, Never> { get }
}

protocol UserInfoViewModelProtocol: UserInfoViewModelInputProtocol, UserInfoViewModelOutputProtocol {
  
}

final class UserInfoViewModel: UserInfoViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<Error, Never>()
  let content = PassthroughSubject<Void, Never>()
  let expandSection = PassthroughSubject<UserInfoExpandSection, Never>()
  let setSectionText = PassthroughSubject<UserInfoSetSectionText, Never>()
  let coutryOfResidenceDidChange = PassthroughSubject<String?, Never>()
  
  private let manager: NetworkManager
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
    switch section.items[indexPath.row].type {
    case .countryOfResidance:
      userInfoModel.countryOfResidence = text
      coutryOfResidenceDidChange.send(text)
    case .fullName:
      switch fieldIndex {
      case 0:
        userInfoModel.fullName.first = text
      case 1:
        userInfoModel.fullName.middle = text
      case 2:
        userInfoModel.fullName.last = text
      default: break
      }
    case .dateOfBirth:
      userInfoModel.dateOfBirth = DateFormatter.defaultFormatter.date(from: text ?? "")
    case .ssn:
      userInfoModel.ssn = text
    case .address:
      switch fieldIndex {
      case 0:
        userInfoModel.address.street = text
      case 1:
        userInfoModel.address.apartment = text
      default: break
      }
    case .city:
      userInfoModel.address.city = text
    case .stateOrRegion, .state:
      userInfoModel.address.region = text
    case .postalCode:
      userInfoModel.address.postalCode = text
    case .useAddressFor1099:
      userInfoModel.canUseAddressFor1099 = UserInfoModel.CanUseAddressFor1099(rawValue: text ?? "")
    }
    
    let isSectionFilled = validator(for: section.type).isFilled(for: userInfoModel)
    setSectionText.send((indexPath, fieldIndex, text, isSectionFilled))
  }
  
}

// MARK: - Private Methods

private extension UserInfoViewModel {
  
  func validator(for section: UserInfoSectionBuilder.Section.SectionType) -> UserInfoValidator {
    switch section {
    case .location: return UserInfoLocationValidator()
    case .personal: return UserInfoPersonalValidator()
    case .contact: return UserInfoContactValidator()
    }
  }
  
}
