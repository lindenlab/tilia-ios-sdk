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

struct UserInfoEmailValidator: UserInfoValidator {
  
  let isVerify: Bool
  
  func isFilled(for model: UserInfoModel) -> Bool {
    if isVerify {
      return SendReceiptValidator.isEmailValid(model.needToVerifyEmail ?? "")
    } else {
      return model.isEmailVerified
    }
  }
  
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
    return model.isUsResident ? !model.tax.isEmpty : !model.tax.signature.isEmpty
  }
  
}

struct UserInfoContactValidator: UserInfoValidator {
  
  func isFilled(for model: UserInfoModel) -> Bool {
    return !model.address.isEmpty
  }
  
}
