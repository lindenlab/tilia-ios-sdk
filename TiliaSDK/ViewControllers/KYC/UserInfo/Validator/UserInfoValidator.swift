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
    return !model.fullName.isEmpty && model.dateOfBirth != nil
  }
  
}

struct UserInfoTaxValidator: UserInfoValidator {
  
  func isFilled(for model: UserInfoModel) -> Bool {
    return !model.tax.isEmpty
  }
  
}

struct UserInfoContactValidator: UserInfoValidator {
  
  func isFilled(for model: UserInfoModel) -> Bool {
    return !model.address.isEmpty
  }
  
}
