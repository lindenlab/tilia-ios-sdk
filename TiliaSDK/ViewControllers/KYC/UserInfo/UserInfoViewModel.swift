//
//  UserInfoViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import Combine
import Foundation

typealias UserInfoSection = (index: Int, isExpanded: Bool, model: UserInfoModel)

protocol UserInfoViewModelInputProtocol {
  func viewDidLoad()
  func updateSection(at index: Int, isExpanded: Bool)
  func setText(_ text: String?, for type: UserInfoSectionBuilder.Section.Item.ItemType, fieldIndex: Int)
}

protocol UserInfoViewModelOutputProtocol {
  var loading: PassthroughSubject<Bool, Never> { get }
  var error: PassthroughSubject<Error, Never> { get }
  var content: PassthroughSubject<Void, Never> { get }
  var section: PassthroughSubject<UserInfoSection, Never> { get }
}

protocol UserInfoViewModelProtocol: UserInfoViewModelInputProtocol, UserInfoViewModelOutputProtocol {
  
}

final class UserInfoViewModel: UserInfoViewModelProtocol {
  
  let loading = PassthroughSubject<Bool, Never>()
  let error = PassthroughSubject<Error, Never>()
  let content = PassthroughSubject<Void, Never>()
  let section = PassthroughSubject<UserInfoSection, Never>()
  
  private let manager: NetworkManager
  private var userInfoModel = UserInfoModel()
  
  init(manager: NetworkManager) {
    self.manager = manager
  }
  
  func viewDidLoad() {
    content.send(())// TODO: - Fix this
  }
  
  func updateSection(at index: Int, isExpanded: Bool) {
    section.send((index, isExpanded, userInfoModel))
  }
  
  func setText(_ text: String?, for type: UserInfoSectionBuilder.Section.Item.ItemType, fieldIndex: Int) {
    switch type {
    case .countryOfResidance:
      userInfoModel.countryOfResidence = text
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
    case .region:
      userInfoModel.address.region = text
    case .postalCode:
      userInfoModel.address.postalCode = text
    case .useAddressFor1099:
      userInfoModel.canUseAddressFor1099 = UserInfoModel.CanUseAddressFor1099(rawValue: text ?? "")
    }
  }
  
}
