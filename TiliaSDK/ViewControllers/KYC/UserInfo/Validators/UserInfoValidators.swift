//
//  UserInfoValidators.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 11.05.2022.
//

import Foundation

protocol UserInfoValidator {
  func isFilled(for model: UserInfoModel) -> Bool
}

struct UserInfoLocationValidator: UserInfoValidator {
  
  func isFilled(for model: UserInfoModel) -> Bool {
    return !model.countryOfResidence.isEmpty
  }
  
}

struct UserInfoPersonalValidator: UserInfoValidator {
  
  func isFilled(for model: UserInfoModel) -> Bool {
    let isFilled = !model.fullName.first.isEmpty
    && !model.fullName.middle.isEmpty
    && !model.fullName.last.isEmpty
    && model.dateOfBirth != nil
    return model.isUsResident ? isFilled && !model.ssn.isEmpty : isFilled
  }
  
}

struct UserInfoContactValidator: UserInfoValidator {
  
  func isFilled(for model: UserInfoModel) -> Bool {
    let isFilled = !model.address.street.isEmpty
    && !model.address.apartment.isEmpty
    && !model.address.street.isEmpty
    && !model.address.city.isEmpty
    && !model.address.region.isEmpty
    && !model.address.postalCode.isEmpty
    return model.isUsResident ? isFilled && model.canUseAddressFor1099 != nil : isFilled
  }
  
}
